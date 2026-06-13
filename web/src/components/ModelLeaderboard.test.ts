import { experimental_AstroContainer as AstroContainer } from "astro/container";
import type { RunMeta } from "@vibe-openscad/runners/src/schema.js";
import { describe, expect, it } from "vitest";
import type { LoadedRun } from "../lib/results.js";
import type { LeaderboardData } from "../lib/leaderboard.js";
import ModelLeaderboard from "./ModelLeaderboard.astro";

function fakeRun(overrides: Partial<RunMeta> = {}): LoadedRun {
  const meta: RunMeta = {
    runId: "r1",
    taskId: "tier-1-a",
    matrixId: "bare/claude-opus-4-7",
    signature: "a".repeat(64),
    fingerprint: {
      schemaVersion: 1,
      taskHash: "b".repeat(64),
      harness: { kind: "bare", provider: "anthropic", model: "claude-opus-4-7" },
      openscadVersion: "OpenSCAD",
      promptTemplateHash: "c".repeat(64),
    },
    provider: "anthropic",
    model: "claude-opus-4-7",
    harness: { kind: "bare" },
    status: "success",
    timing: { totalMs: 2000 },
    tokens: { input: 100, output: 50 },
    cost_usd: 0.01,
    createdAt: "2026-04-01T00:00:00.000Z",
    ...overrides,
  };
  return {
    meta,
    scadUrl: `/results/${meta.taskId}/${meta.runId}/final.scad`,
    pngUrl: `/results/${meta.taskId}/${meta.runId}/final.png`,
  };
}

function makeData(): LeaderboardData {
  const taskA = { id: "tier-1-a", slug: "a", title: "Task A", tier: 1 };
  const taskB = { id: "tier-2-b", slug: "b", title: "Task B", tier: 2 };
  return {
    tasks: [taskA, taskB],
    rows: [
      {
        model: "claude-opus-4-7",
        provider: "anthropic",
        tasksAttempted: 2,
        successCount: 1,
        successRate: 0.5,
        avgLatencyMs: 2000,
        avgCostUsd: 0.01,
        totalCostUsd: 0.02,
        hasCost: true,
        totalRuns: 5,
        cells: [
          { task: taskA, run: fakeRun({ runId: "ok" }), status: "success" },
          { task: taskB, run: null, status: null },
        ],
      },
    ],
  };
}

describe("ModelLeaderboard", () => {
  it("renders a row per model with the success percentage", async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(ModelLeaderboard, {
      props: { data: makeData() },
    });
    expect(html).toContain("claude opus 4.7"); // short label
    expect(html).toContain("50%");
    expect(html).toContain("1/2"); // successCount/attempted
  });

  it("renders a lightbox-able thumbnail for an attempted task and an empty cell for a skipped one", async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(ModelLeaderboard, {
      props: { data: makeData() },
    });
    // attempted: button.lb-thumb with data-img pointing at the run png
    expect(html).toContain('data-img="/results/tier-1-a/ok/final.png"');
    expect(html).toContain('data-col="0"');
    // skipped: an empty placeholder cell
    expect(html).toContain("lb-thumb empty");
  });

  it("exposes sort data attributes used by the client-side sorter", async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(ModelLeaderboard, {
      props: { data: makeData() },
    });
    expect(html).toContain('data-success="0.5"');
    expect(html).toContain('data-latency="2000"');
    expect(html).toContain('data-cost="0.01"');
  });

  it("renders sort and status-legend controls plus the lightbox", async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(ModelLeaderboard, {
      props: { data: makeData() },
    });
    expect(html).toContain('data-sort-key="success"');
    expect(html).toContain('data-sort-key="cost"');
    expect(html).toContain('legend-item');
    expect(html).toContain('data-lightbox');
  });
});
