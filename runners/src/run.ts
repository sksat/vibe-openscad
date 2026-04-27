#!/usr/bin/env node
import { execSync } from "node:child_process";
import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { canonicalJson } from "./canonical.js";
import {
  type Failure,
  failuresSection,
  header,
  itemLine,
  summary,
} from "./format.js";
import { runBare } from "./harnesses/bare.js";
import type { ParentRunContext } from "./harnesses/types.js";
import { getOpenscadVersion } from "./env.js";
import { type Candidate, expandMatrix, loadBenchConfig } from "./matrix.js";
import type { MatrixEntry } from "./schema.js";

type BareEntry = Extract<MatrixEntry, { harness: { kind: "bare" } }>;
import { type PlanItem, planRuns } from "./plan.js";
import { computeCostUsd } from "./pricing.js";
import { createAnthropicProvider } from "./providers/anthropic.js";
import { createGoogleProvider } from "./providers/google.js";
import { createOpenaiProvider } from "./providers/openai.js";
import type { Provider } from "./providers/types.js";
import { renderScad } from "./render.js";
import {
  findRunsFor,
  indexResults,
  pruneOldRuns,
  writeRunResult,
} from "./results.js";
import type {
  BenchConfig,
  Fingerprint,
  RunMeta,
  RunStatus,
} from "./schema.js";
import { computeSignature, shortSignature } from "./signature.js";
import { computeTaskHash, loadAllTasks } from "./tasks.js";

interface Args {
  command: "plan" | "run" | "show" | "rerender" | "help";
  filter?: string;
  force: boolean;
  prune: boolean;
  samples?: number;
  showRunId?: string;
  rootDir: string;
}

const PROMPT_TEMPLATE_VERSION = "v1";

function findRepoRoot(start: string): string {
  let dir = start;
  for (let i = 0; i < 10; i++) {
    try {
      readFileSync(join(dir, "bench-config.yml"));
      return dir;
    } catch {
      const parent = dirname(dir);
      if (parent === dir) break;
      dir = parent;
    }
  }
  return start;
}

function parseArgs(argv: string[]): Args {
  const args: Args = {
    command: "help",
    force: false,
    prune: false,
    rootDir: findRepoRoot(process.cwd()),
  };
  const rest = argv.slice(2);
  if (rest.length === 0 || rest[0] === "--help" || rest[0] === "-h") {
    return args;
  }
  const cmd = rest[0];
  if (cmd === "plan" || cmd === "run" || cmd === "rerender") {
    args.command = cmd;
  } else if (cmd === "show") {
    args.command = "show";
    if (rest[1] !== undefined) args.showRunId = rest[1];
    return args;
  } else {
    throw new Error(`unknown command: ${cmd}`);
  }
  for (let i = 1; i < rest.length; i++) {
    const a = rest[i];
    if (a === "--force") args.force = true;
    else if (a === "--prune") args.prune = true;
    else if (a === "--filter") {
      const v = rest[++i];
      if (v !== undefined) args.filter = v;
    }
    else if (a === "--samples") args.samples = Number(rest[++i]);
    else if (a === "--root") args.rootDir = resolve(rest[++i] ?? ".");
    else throw new Error(`unknown flag: ${a}`);
  }
  return args;
}

function printHelp(): void {
  console.log(`bench — vibe-openscad runner

Usage:
  bench plan [--filter <id>] [--root <dir>]
  bench run  [--filter <id>] [--force] [--samples N] [--root <dir>]
  bench rerender [--filter <id>] [--root <dir>]
  bench show <runId> [--root <dir>]

Commands:
  plan      Show what would run (does NOT call any API).
  run       Execute missing/stale candidates only (calls APIs; needs API keys).
  rerender  Re-run \`openscad\` on existing successful runs to refresh STL/PNG
            (no API calls; useful after camera/imgsize changes).
  show      Pretty-print a single run's meta.json.

Flags:
  --filter <pattern>   Substring match against matrixId or taskId. Use ':'
                       to AND multiple terms (e.g. 'gemini:mug').
  --force              Re-run even if up-to-date.
  --prune              When persisting a run, delete prior runs for the same
                       (task, matrix). Default keeps history and warns.
  --samples N          Override defaults.samples from bench-config.yml.
`);
}

function fingerprintFor(
  candidate: Candidate,
  openscadVersion: string,
  taskHash: string,
  promptTemplateHash: string,
  resolveParentSignature?: (parentMatrixId: string) => string,
): Fingerprint {
  const entry = candidate.entry;
  if (entry.harness.kind === "bare") {
    const e = entry as BareEntry;
    let parentSignature: string | undefined;
    if (e.harness.iterateFrom) {
      if (!resolveParentSignature) {
        throw new Error(
          `fingerprintFor: ${e.id} has iterateFrom but no parent signature resolver was provided`,
        );
      }
      parentSignature = resolveParentSignature(e.harness.iterateFrom);
    }
    return {
      schemaVersion: 1,
      taskHash,
      harness: {
        kind: "bare",
        provider: e.provider,
        model: e.model,
        ...(e.modelOptions ? { modelOptions: e.modelOptions } : {}),
        ...(e.revision ? { revision: e.revision } : {}),
        ...(e.harness.iterateFrom
          ? { iterateFrom: e.harness.iterateFrom }
          : {}),
        ...(e.harness.iteration ? { iteration: e.harness.iteration } : {}),
        ...(parentSignature ? { parentSignature } : {}),
      },
      openscadVersion,
      promptTemplateHash,
    };
  }
  type ExternalAgentEntry = Extract<
    MatrixEntry,
    { harness: { kind: "external-agent" } }
  >;
  const e = entry as ExternalAgentEntry;
  return {
    schemaVersion: 1,
    taskHash,
    harness: {
      kind: "external-agent",
      agent: e.harness.agent,
      agentVersion: "unknown",
      maxTurns: e.harness.maxTurns,
      allowedTools: e.harness.allowedTools ?? [],
      ...(e.modelHint ? { modelHint: e.modelHint } : {}),
    },
    openscadVersion,
    promptTemplateHash,
  };
}

function providerFor(name: string): Provider {
  switch (name) {
    case "anthropic":
      return createAnthropicProvider();
    case "google":
      return createGoogleProvider();
    case "openai":
      return createOpenaiProvider();
    default:
      throw new Error(`provider not yet implemented: ${name}`);
  }
}

/**
 * Filter spec: a colon-separated list of substrings, all of which must
 * match against the candidate's matrixId, taskId, or any of the extra
 * fields (e.g. provider, model). Single-term filters (no colon) match
 * the way the previous behaviour did.
 *
 *   "haiku"            → contains "haiku"
 *   "claude:haiku"     → contains "claude" AND "haiku"
 *   "openai:mug"       → "openai" hits the provider, "mug" hits the task
 */
function matchesFilter(
  spec: string,
  entryId: string,
  taskId: string,
  ...extras: (string | undefined)[]
): boolean {
  const terms = spec
    .split(/[:,+]/)
    .map((s) => s.trim())
    .filter(Boolean);
  if (terms.length === 0) return true;
  const haystacks = [entryId, taskId, ...extras.filter((s): s is string => !!s)];
  return terms.every((term) => haystacks.some((h) => h.includes(term)));
}

function getGitCommit(): string | undefined {
  try {
    return execSync("git rev-parse HEAD", { stdio: ["ignore", "pipe", "ignore"] })
      .toString()
      .trim();
  } catch {
    return undefined;
  }
}

function candidateName(item: PlanItem): string {
  return `${item.candidate.entry.id}::${item.candidate.task.id}`;
}

function isColorTty(): boolean {
  return Boolean(process.stdout.isTTY) && process.env["NO_COLOR"] === undefined;
}

function formatCostShort(usd: number): string {
  if (usd === 0) return "$0";
  if (usd < 0.0001) return "<$0.0001";
  if (usd < 1) return `$${usd.toFixed(4)}`;
  return `$${usd.toFixed(2)}`;
}

function printPlan(items: PlanItem[]): void {
  const color = isColorTty();
  console.log(header(items.length, items.length === 1 ? "candidate" : "candidates"));
  let nMissing = 0;
  let nStale = 0;
  let nUp = 0;
  for (const item of items) {
    console.log(
      itemLine(
        { verb: "plan", name: candidateName(item), status: item.status },
        { color },
      ),
    );
    if (item.status === "missing") nMissing++;
    else if (item.status === "stale") nStale++;
    else nUp++;
  }
  console.log("");
  console.log(
    summary(
      {
        kind: "plan",
        counts: { missing: nMissing, stale: nStale, upToDate: nUp },
      },
      { color },
    ),
  );
}

interface ExecutionOutcome {
  meta: RunMeta;
  /** True when meta + artifacts were written to results/. */
  persisted: boolean;
  errorDetail?: string;
}

/**
 * Statuses we persist to results/. Transient infra failures
 * (api_error, timeout) are NOT persisted: they reflect a broken benchmark
 * precondition (missing API key, network down, rate-limited), not a real
 * sample of the model's output.
 */
const PERSISTED_STATUSES: ReadonlySet<RunStatus> = new Set<RunStatus>([
  "success",
  "no_code",
  "render_error",
  "submit_missing",
]);

/**
 * Locate the most recent run for a (task, matrixId) pair whose artifacts
 * are usable as feedback for the next iteration step. Accepts:
 *
 *   - `success`       — final.scad + final.png 両方あり、PNG feedback OK
 *   - `render_error`  — final.scad はあるが PNG 無し。harness が
 *                       buildFeedbackMessages 内で error-text fallback する
 *
 * 拒否: `no_code` / `submit_missing` / `timeout` / `api_error` —
 * SCAD 自体が無いので chain を続ける材料が無い。
 */
function findLatestUsableParentRun(
  resultsDir: string,
  taskId: string,
  matrixId: string,
): RunMeta | undefined {
  const idx = indexResults(resultsDir);
  const candidates = idx.all
    .filter(
      (m) =>
        m.taskId === taskId &&
        m.matrixId === matrixId &&
        (m.status === "success" || m.status === "render_error"),
    )
    .sort((a, b) => (a.createdAt < b.createdAt ? 1 : -1));
  return candidates[0];
}

function loadParentContext(
  resultsDir: string,
  parent: RunMeta,
): ParentRunContext {
  const runDir = join(resultsDir, parent.taskId, parent.runId);
  const scad = readFileSync(join(runDir, "final.scad"), "utf8");
  let png: Buffer | undefined;
  try {
    png = readFileSync(join(runDir, "final.png"));
  } catch {
    // PNG is optional — strategies that need it will fall back to text.
  }
  return {
    runId: parent.runId,
    scad,
    ...(png ? { png } : {}),
    ...(parent.error ? { errorMessage: parent.error } : {}),
  };
}

async function executeBareRun(
  item: PlanItem,
  cfg: BenchConfig,
  resultsDir: string,
  prune: boolean,
): Promise<ExecutionOutcome> {
  void cfg;
  const entry = item.candidate.entry;
  if (entry.harness.kind !== "bare") {
    throw new Error(
      `harness not implemented in run.ts: ${entry.harness.kind}`,
    );
  }
  const bareEntry = entry as BareEntry;
  const provider = providerFor(bareEntry.provider);

  let parent: ParentRunContext | undefined;
  if (entry.harness.iterateFrom) {
    const parentMeta = findLatestUsableParentRun(
      resultsDir,
      item.candidate.task.id,
      entry.harness.iterateFrom,
    );
    if (!parentMeta) {
      throw new Error(
        `iterateFrom: no usable run found for predecessor matrixId="${entry.harness.iterateFrom}" task="${item.candidate.task.id}". The predecessor needs to be at least render_error (have a SCAD artifact) for the chain to continue. Run the predecessor first or skip this entry.`,
      );
    }
    parent = loadParentContext(resultsDir, parentMeta);
  }

  const result = await runBare({
    task: item.candidate.task,
    config: {
      kind: "bare",
      provider,
      model: bareEntry.model,
      ...(bareEntry.modelOptions
        ? { modelOptions: bareEntry.modelOptions }
        : {}),
      ...(entry.harness.iteration
        ? { iteration: entry.harness.iteration }
        : {}),
    },
    render: (scad) => renderScad(scad),
    ...(parent ? { parent } : {}),
  });

  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const sigShort = shortSignature(item.signature);
  const idSafe = entry.id.replace(/\//g, "_");
  const runId = `${idSafe}-${sigShort}-${timestamp}`;

  const harnessLog = result.harnessLog;
  const cost =
    result.tokens != null
      ? computeCostUsd(bareEntry.provider, bareEntry.model, result.tokens)
      : null;
  const meta: RunMeta = {
    runId,
    taskId: item.candidate.task.id,
    matrixId: entry.id,
    signature: item.signature,
    fingerprint: item.fingerprint,
    provider: bareEntry.provider,
    model: bareEntry.model,
    harness: harnessLog,
    status: result.status,
    timing: { totalMs: Math.round(result.durationMs) },
    ...(result.tokens ? { tokens: result.tokens } : {}),
    ...(cost !== null ? { cost_usd: cost } : {}),
    createdAt: new Date().toISOString(),
    ...(getGitCommit() ? { gitCommit: getGitCommit() } : {}),
    ...(result.errorMessage ? { error: result.errorMessage } : {}),
    ...(parent ? { parentRunId: parent.runId } : {}),
  };

  const persisted = PERSISTED_STATUSES.has(result.status);
  if (persisted) {
    if (prune) {
      const removed = pruneOldRuns(
        resultsDir,
        item.candidate.task.id,
        entry.id,
      );
      if (removed.length > 0) {
        console.warn(
          `  [prune] removed ${removed.length} prior run(s): ${removed.join(", ")}`,
        );
      }
    } else {
      const existing = findRunsFor(
        resultsDir,
        item.candidate.task.id,
        entry.id,
      );
      if (existing.length > 0) {
        console.warn(
          `  [warn] ${existing.length} prior run(s) for ${entry.id}::${item.candidate.task.id} kept (pass --prune to replace): ${existing.join(", ")}`,
        );
      }
    }
    writeRunResult(resultsDir, meta, {
      prompt: item.candidate.task.prompt,
      finalScad: result.scad ?? "",
      ...(result.stl ? { finalStl: result.stl } : {}),
      ...(result.png ? { finalPng: result.png } : {}),
    });
  }

  return result.errorMessage
    ? { meta, persisted, errorDetail: result.errorMessage }
    : { meta, persisted };
}

async function runRerender(resultsDir: string, filter?: string): Promise<void> {
  const idx = indexResults(resultsDir);
  const targets = idx.all.filter((m) => {
    if (m.status !== "success") return false;
    if (!filter) return true;
    return matchesFilter(filter, m.matrixId, m.taskId);
  });
  const color = isColorTty();
  console.log(header(targets.length, targets.length === 1 ? "run" : "runs"));
  if (targets.length === 0) {
    console.log("\nNothing to rerender.");
    return;
  }
  let passed = 0;
  let failed = 0;
  const failures: Failure[] = [];
  const start = performance.now();
  for (const meta of targets) {
    const name = `${meta.matrixId}::${meta.taskId}`;
    process.stdout.write(`rerender ${name} ... `);
    const runDir = join(resultsDir, meta.taskId, meta.runId);
    try {
      const scad = readFileSync(join(runDir, "final.scad"), "utf8");
      const r = await renderScad(scad);
      const fs = await import("node:fs");
      fs.writeFileSync(join(runDir, "final.stl"), r.stl);
      fs.writeFileSync(join(runDir, "final.png"), r.png);
      console.log(
        itemLine({ verb: "rerender", name, status: "ok" }, { color }).replace(
          /^rerender .* \.\.\. /,
          "",
        ),
      );
      passed++;
    } catch (e) {
      console.log(
        itemLine(
          { verb: "rerender", name, status: "FAILED", hint: "render_error" },
          { color },
        ).replace(/^rerender .* \.\.\. /, ""),
      );
      failures.push({ name, detail: (e as Error).message });
      failed++;
    }
  }
  const failuresOut = failuresSection(failures, { color });
  if (failuresOut) process.stdout.write(failuresOut);
  console.log("");
  console.log(
    summary(
      {
        kind: "bench",
        ok: failed === 0,
        counts: { passed, failed, skipped: 0 },
        durationMs: performance.now() - start,
      },
      { color },
    ),
  );
}

async function main(): Promise<void> {
  const args = parseArgs(process.argv);

  if (args.command === "help") {
    printHelp();
    return;
  }

  // Load <repoRoot>/.env into process.env if present. Node 22+ ships
  // process.loadEnvFile; we ignore the missing-file case so .env is optional.
  try {
    const envPath = join(args.rootDir, ".env");
    process.loadEnvFile(envPath);
  } catch {
    // no .env, or runtime doesn't support loadEnvFile — proceed without
  }

  const root = args.rootDir;
  const tasksDir = join(root, "tasks");
  const configPath = join(root, "bench-config.yml");
  const resultsDir = join(root, "results");

  if (args.command === "rerender") {
    await runRerender(resultsDir, args.filter);
    return;
  }

  if (args.command === "show") {
    if (!args.showRunId) {
      throw new Error("usage: bench show <runId>");
    }
    const idx = indexResults(resultsDir);
    const meta = idx.all.find((m) => m.runId === args.showRunId);
    if (!meta) {
      throw new Error(`run not found: ${args.showRunId}`);
    }
    console.log(JSON.stringify(meta, null, 2));
    return;
  }

  const tasks = loadAllTasks(tasksDir);
  let cfg = loadBenchConfig(configPath);
  if (args.samples !== undefined) {
    cfg = { ...cfg, defaults: { ...cfg.defaults, samples: args.samples } };
  }

  const candidates = expandMatrix(cfg, tasks);
  const filtered = args.filter
    ? candidates.filter((c) => {
        const extras: string[] = [];
        if (c.entry.harness.kind === "bare") {
          const e = c.entry as Extract<MatrixEntry, { harness: { kind: "bare" } }>;
          extras.push(e.provider, e.model);
        } else if (c.entry.harness.kind === "external-agent") {
          extras.push(c.entry.harness.agent);
        }
        return matchesFilter(args.filter!, c.entry.id, c.task.id, ...extras);
      })
    : candidates;

  const openscadVersion = await getOpenscadVersion();
  const fingerprintCache = new WeakMap<Candidate, Fingerprint>();
  const promptTemplateHash = createHash("sha256")
    .update(PROMPT_TEMPLATE_VERSION)
    .digest("hex");
  // Look up parent (entry, task) pairs from the full candidate set so that
  // filtering with --filter doesn't break parent-signature resolution.
  const candidatesByMatrixTask = new Map<string, Candidate>();
  for (const c of candidates) {
    candidatesByMatrixTask.set(`${c.entry.id}::${c.task.id}`, c);
  }
  const visiting = new Set<string>();
  const computeFingerprint = (c: Candidate): Fingerprint => {
    const cached = fingerprintCache.get(c);
    if (cached) return cached;
    const key = `${c.entry.id}::${c.task.id}`;
    if (visiting.has(key)) {
      throw new Error(
        `iterateFrom cycle detected involving "${c.entry.id}" (task "${c.task.id}"). Check bench-config.yml.`,
      );
    }
    visiting.add(key);
    try {
      const fp = fingerprintFor(
        c,
        openscadVersion,
        computeTaskHash(c.task),
        promptTemplateHash,
        (parentMatrixId) => {
          const parentKey = `${parentMatrixId}::${c.task.id}`;
          const parent = candidatesByMatrixTask.get(parentKey);
          if (!parent) {
            throw new Error(
              `iterateFrom resolution failed: ${c.entry.id} references unknown predecessor matrixId="${parentMatrixId}" for task "${c.task.id}". Did you forget to add it to bench-config.yml?`,
            );
          }
          return computeSignature(computeFingerprint(parent));
        },
      );
      fingerprintCache.set(c, fp);
      return fp;
    } finally {
      visiting.delete(key);
    }
  };

  const existing = indexResults(resultsDir);
  const items = planRuns({
    cfg,
    candidates: filtered,
    existing,
    computeFingerprint,
    computeSignature,
  });

  if (args.command === "plan") {
    printPlan(items);
    return;
  }

  // run
  const todo = args.force
    ? items
    : items.filter((i) => i.status !== "up-to-date");
  const skipped = items.length - todo.length;

  const color = isColorTty();
  console.log(header(todo.length, todo.length === 1 ? "candidate" : "candidates"));
  if (todo.length === 0) {
    console.log("");
    console.log(
      summary(
        {
          kind: "bench",
          ok: true,
          counts: { passed: 0, failed: 0, skipped },
          durationMs: 0,
        },
        { color },
      ),
    );
    return;
  }

  let passed = 0;
  let failed = 0;
  let totalCost = 0;
  const failures: Failure[] = [];
  const runStarted = performance.now();

  for (const item of todo) {
    const name = candidateName(item);
    process.stdout.write(`bench ${name} ... `);
    try {
      const outcome = await executeBareRun(item, cfg, resultsDir, args.prune);
      const meta = outcome.meta;
      if (meta.status === "success") {
        passed++;
        if (typeof meta.cost_usd === "number") totalCost += meta.cost_usd;
        const parts = [`${(meta.timing.totalMs / 1000).toFixed(1)}s`];
        if (meta.tokens) {
          parts.push(`${meta.tokens.input}in/${meta.tokens.output}out`);
        }
        if (typeof meta.cost_usd === "number") {
          parts.push(formatCostShort(meta.cost_usd));
        }
        console.log(
          itemLine(
            { verb: "bench", name, status: "ok", hint: parts.join(", ") },
            { color },
          ).replace(/^bench .* \.\.\. /, ""),
        );
      } else {
        failed++;
        if (typeof meta.cost_usd === "number") totalCost += meta.cost_usd;
        const hint =
          typeof meta.cost_usd === "number"
            ? `${meta.status}, ${formatCostShort(meta.cost_usd)}`
            : meta.status;
        console.log(
          itemLine(
            { verb: "bench", name, status: "FAILED", hint },
            { color },
          ).replace(/^bench .* \.\.\. /, ""),
        );
        failures.push({
          name,
          detail: outcome.errorDetail ?? `(no detail; status=${meta.status})`,
        });
      }
    } catch (e) {
      failed++;
      console.log(
        itemLine(
          { verb: "bench", name, status: "FAILED", hint: "exception" },
          { color },
        ).replace(/^bench .* \.\.\. /, ""),
      );
      failures.push({ name, detail: (e as Error).stack ?? (e as Error).message });
    }
  }

  const elapsed = performance.now() - runStarted;
  const failuresOut = failuresSection(failures, { color });
  if (failuresOut) process.stdout.write(failuresOut);
  console.log("");
  console.log(
    summary(
      {
        kind: "bench",
        ok: failed === 0,
        counts: { passed, failed, skipped },
        durationMs: elapsed,
      },
      { color },
    ),
  );
  if (totalCost > 0) {
    console.log(`bench cost: ${formatCostShort(totalCost)}`);
  }

  if (failed > 0) process.exitCode = 1;
}

// only invoke main when run directly via tsx/node (skip when imported in tests)
const isMain = (() => {
  if (typeof process === "undefined" || !process.argv[1]) return false;
  const entry = process.argv[1];
  // when running `tsx src/run.ts`, argv[1] ends with run.ts
  return entry.endsWith("run.ts") || entry.endsWith("run.js");
})();

if (isMain) {
  main().catch((e) => {
    console.error(e);
    process.exit(1);
  });
}

// silence unused-warning noise
void canonicalJson;
