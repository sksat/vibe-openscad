import {
  existsSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { join } from "node:path";
import { type RunMeta, RunMetaSchema } from "./schema.js";

export interface RunArtifacts {
  prompt: string;
  finalScad: string;
  finalStl?: Buffer;
  finalPng?: Buffer;
  agentLog?: string;
}

export function writeRunResult(
  resultsDir: string,
  meta: RunMeta,
  artifacts: RunArtifacts,
): void {
  const runDir = join(resultsDir, meta.taskId, meta.runId);
  if (existsSync(runDir)) {
    throw new Error(`run dir already exists: ${runDir}`);
  }
  mkdirSync(runDir, { recursive: true });
  writeFileSync(join(runDir, "meta.json"), JSON.stringify(meta, null, 2));
  writeFileSync(join(runDir, "prompt.md"), artifacts.prompt);
  writeFileSync(join(runDir, "final.scad"), artifacts.finalScad);
  if (artifacts.finalStl) {
    writeFileSync(join(runDir, "final.stl"), artifacts.finalStl);
  }
  if (artifacts.finalPng) {
    writeFileSync(join(runDir, "final.png"), artifacts.finalPng);
  }
  if (artifacts.agentLog) {
    writeFileSync(join(runDir, "agent-log.jsonl"), artifacts.agentLog);
  }
}

export function loadRunMeta(metaPath: string): RunMeta {
  const raw = JSON.parse(readFileSync(metaPath, "utf8"));
  return RunMetaSchema.parse(raw);
}

/** List run directory names under `<resultsDir>/<taskId>/` belonging to the
 *  given matrix entry, without deleting anything. */
export function findRunsFor(
  resultsDir: string,
  taskId: string,
  matrixId: string,
): string[] {
  const taskDir = join(resultsDir, taskId);
  const found: string[] = [];
  if (!existsSync(taskDir)) return found;
  for (const child of readdirSync(taskDir)) {
    const metaPath = join(taskDir, child, "meta.json");
    if (!existsSync(metaPath)) continue;
    try {
      const m = JSON.parse(readFileSync(metaPath, "utf8"));
      if (m.matrixId === matrixId) found.push(child);
    } catch {
      // malformed meta — skip
    }
  }
  return found;
}

/**
 * Delete previous runs under `<resultsDir>/<taskId>/` that belong to the
 * given matrix entry. Off by default; opt-in via `bench run --prune` when
 * you want to replace older attempts (e.g. a failure that has since been
 * retried to success).
 */
export function pruneOldRuns(
  resultsDir: string,
  taskId: string,
  matrixId: string,
): string[] {
  const found = findRunsFor(resultsDir, taskId, matrixId);
  for (const child of found) {
    rmSync(join(resultsDir, taskId, child), { recursive: true, force: true });
  }
  return found;
}

export interface ResultsIndex {
  bySignature: Map<string, RunMeta[]>;
  all: RunMeta[];
}

export function indexResults(resultsDir: string): ResultsIndex {
  const all: RunMeta[] = [];
  const bySignature = new Map<string, RunMeta[]>();

  if (!existsSync(resultsDir)) {
    return { all, bySignature };
  }

  for (const taskId of readdirSync(resultsDir).sort()) {
    const taskDir = join(resultsDir, taskId);
    if (!statSync(taskDir).isDirectory()) continue;
    for (const runId of readdirSync(taskDir).sort()) {
      const metaPath = join(taskDir, runId, "meta.json");
      if (!existsSync(metaPath)) continue;
      const meta = loadRunMeta(metaPath);
      all.push(meta);
      const list = bySignature.get(meta.signature) ?? [];
      list.push(meta);
      bySignature.set(meta.signature, list);
    }
  }
  return { all, bySignature };
}
