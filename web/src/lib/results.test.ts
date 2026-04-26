import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { RunMeta } from "@vibe-openscad/runners/src/schema.js";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { loadDataset } from "./results.js";

let dir: string;

beforeEach(() => {
  dir = mkdtempSync(join(tmpdir(), "web-loader-"));
});

afterEach(() => {
  rmSync(dir, { recursive: true, force: true });
});

const taskYaml = (id: string, tier = 1) => `
id: ${id}
tier: ${tier}
title: Task ${id}
prompt: do ${id}
`;

function meta(overrides: Partial<RunMeta>): RunMeta {
  return {
    runId: "run-x",
    taskId: "tier-1-cube",
    matrixId: "bare/claude-opus-4-7",
    signature: "a".repeat(64),
    fingerprint: {
      schemaVersion: 1,
      taskHash: "b".repeat(64),
      harness: { kind: "bare", provider: "anthropic", model: "claude-opus-4-7" },
      openscadVersion: "OpenSCAD 2026.04.27",
      promptTemplateHash: "c".repeat(64),
    },
    provider: "anthropic",
    model: "claude-opus-4-7",
    harness: { kind: "bare" },
    status: "success",
    timing: { totalMs: 5000 },
    createdAt: "2026-04-27T01:00:00Z",
    ...overrides,
  };
}

function writeRun(rootResults: string, m: RunMeta, opts: { png?: boolean; stl?: boolean } = {}): void {
  const runDir = join(rootResults, m.taskId, m.runId);
  mkdirSync(runDir, { recursive: true });
  writeFileSync(join(runDir, "meta.json"), JSON.stringify(m));
  writeFileSync(join(runDir, "prompt.md"), "p");
  writeFileSync(join(runDir, "final.scad"), "cube();");
  if (opts.png !== false) writeFileSync(join(runDir, "final.png"), "");
  if (opts.stl !== false) writeFileSync(join(runDir, "final.stl"), "");
}

function setup(): { repoRoot: string; tasksDir: string; resultsDir: string } {
  const tasksDir = join(dir, "tasks", "tier-1");
  const resultsDir = join(dir, "results");
  mkdirSync(tasksDir, { recursive: true });
  mkdirSync(resultsDir, { recursive: true });
  writeFileSync(join(tasksDir, "01-cube.yml"), taskYaml("tier-1-cube"));
  writeFileSync(join(tasksDir, "02-mug.yml"), taskYaml("tier-1-mug"));
  return { repoRoot: dir, tasksDir, resultsDir };
}

describe("loadDataset", () => {
  it("returns empty runs and intact tasks when results/ is empty", () => {
    const { repoRoot } = setup();
    const ds = loadDataset(repoRoot);
    expect(ds.tasks.map((t) => t.task.id).sort()).toEqual([
      "tier-1-cube",
      "tier-1-mug",
    ]);
    expect(ds.runs.size).toBe(0);
    for (const t of ds.tasks) expect(t.runs).toEqual([]);
  });

  it("loads runs and groups them under their tasks", () => {
    const { repoRoot, resultsDir } = setup();
    writeRun(resultsDir, meta({ runId: "r1", taskId: "tier-1-cube" }));
    writeRun(
      resultsDir,
      meta({
        runId: "r2",
        taskId: "tier-1-mug",
        model: "claude-haiku-4-5",
        matrixId: "bare/claude-haiku-4-5",
      }),
    );

    const ds = loadDataset(repoRoot);
    const cube = ds.tasks.find((t) => t.task.id === "tier-1-cube");
    const mug = ds.tasks.find((t) => t.task.id === "tier-1-mug");
    expect(cube?.runs.map((r) => r.meta.runId)).toEqual(["r1"]);
    expect(mug?.runs.map((r) => r.meta.runId)).toEqual(["r2"]);
    expect(ds.runs.get("r1")?.meta.taskId).toBe("tier-1-cube");
  });

  it("exposes pngUrl and stlUrl pointing under /results/", () => {
    const { repoRoot, resultsDir } = setup();
    writeRun(resultsDir, meta({ runId: "r1", taskId: "tier-1-cube" }));
    const ds = loadDataset(repoRoot);
    const r = ds.runs.get("r1");
    expect(r?.pngUrl).toBe("/results/tier-1-cube/r1/final.png");
    expect(r?.stlUrl).toBe("/results/tier-1-cube/r1/final.stl");
    expect(r?.scadUrl).toBe("/results/tier-1-cube/r1/final.scad");
  });

  it("omits pngUrl/stlUrl when those files are missing (e.g. no_code, render_error)", () => {
    const { repoRoot, resultsDir } = setup();
    writeRun(
      resultsDir,
      meta({ runId: "r1", taskId: "tier-1-cube", status: "no_code" }),
      { png: false, stl: false },
    );
    const r = loadDataset(repoRoot).runs.get("r1");
    expect(r?.pngUrl).toBeUndefined();
    expect(r?.stlUrl).toBeUndefined();
  });

  it("surfaces sub-agent models in facets", () => {
    const { repoRoot, resultsDir } = setup();
    const m: RunMeta = meta({
      runId: "r-ea",
      taskId: "tier-1-cube",
      matrixId: "claude-code/claude-opus-4-7",
      fingerprint: {
        schemaVersion: 1,
        taskHash: "b".repeat(64),
        harness: {
          kind: "external-agent",
          agent: "claude-code",
          agentVersion: "0.5.0",
          maxTurns: 8,
          allowedTools: ["mcp__bench__render_openscad"],
          subagents: [
            {
              name: "verifier",
              provider: "anthropic",
              model: "claude-haiku-4-5",
              role: "review_render",
            },
          ],
        },
        openscadVersion: "OpenSCAD 2026.04.27",
        promptTemplateHash: "c".repeat(64),
      },
      harness: {
        kind: "external-agent",
        agent: "claude-code",
        agentVersion: "0.5.0",
        maxTurns: 8,
        turnsUsed: 4,
        renderCalls: 3,
        subagents: [
          {
            name: "verifier",
            provider: "anthropic",
            model: "claude-haiku-4-5",
            invocations: 2,
          },
        ],
      },
    });
    writeRun(resultsDir, m);
    const ds = loadDataset(repoRoot);
    expect(ds.facets.subagentModels).toContain("claude-haiku-4-5");
    expect(ds.facets.harnessKinds).toContain("external-agent");
  });

  it("collects unique facets useful for client-side filtering", () => {
    const { repoRoot, resultsDir } = setup();
    writeRun(resultsDir, meta({ runId: "r1", taskId: "tier-1-cube" }));
    writeRun(
      resultsDir,
      meta({
        runId: "r2",
        taskId: "tier-1-cube",
        model: "claude-haiku-4-5",
        matrixId: "bare/claude-haiku-4-5",
      }),
    );
    const ds = loadDataset(repoRoot);
    expect(ds.facets.models.sort()).toEqual([
      "claude-haiku-4-5",
      "claude-opus-4-7",
    ]);
    expect(ds.facets.providers).toEqual(["anthropic"]);
    expect(ds.facets.harnessKinds).toEqual(["bare"]);
    expect(ds.facets.matrixIds.sort()).toEqual([
      "bare/claude-haiku-4-5",
      "bare/claude-opus-4-7",
    ]);
  });

  it("sorts runs within a task by createdAt descending", () => {
    const { repoRoot, resultsDir } = setup();
    writeRun(
      resultsDir,
      meta({ runId: "r-old", taskId: "tier-1-cube", createdAt: "2026-04-01T00:00:00Z" }),
    );
    writeRun(
      resultsDir,
      meta({ runId: "r-new", taskId: "tier-1-cube", createdAt: "2026-04-27T00:00:00Z" }),
    );
    const ds = loadDataset(repoRoot);
    const cube = ds.tasks.find((t) => t.task.id === "tier-1-cube");
    expect(cube?.runs.map((r) => r.meta.runId)).toEqual(["r-new", "r-old"]);
  });
});
