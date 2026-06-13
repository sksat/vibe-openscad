import { describe, expect, it } from "vitest";
import type { RunMeta, Task } from "@vibe-openscad/runners/src/schema.js";
import type { LoadedRun } from "./results.js";
import { buildLeaderboard, isBaselineRun } from "./leaderboard.js";

function fakeMeta(overrides: Partial<RunMeta> = {}): RunMeta {
  const base: RunMeta = {
    runId: "r",
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
    timing: { totalMs: 1000 },
    createdAt: "2026-04-01T00:00:00.000Z",
    ...overrides,
  };
  return base;
}

function fakeRun(overrides: Partial<RunMeta> = {}): LoadedRun {
  const meta = fakeMeta(overrides);
  return {
    meta,
    scadUrl: `/results/${meta.taskId}/${meta.runId}/final.scad`,
    pngUrl: `/results/${meta.taskId}/${meta.runId}/final.png`,
  };
}

function task(id: string, tier: number, title = id): Task {
  return { id, tier, title, prompt: "p" };
}

/** Build an iter fingerprint so harnessGroupSlug() returns iter-png. */
function iterMeta(overrides: Partial<RunMeta> = {}): RunMeta {
  return fakeMeta({
    matrixId: "iter-png-1/claude-opus-4-7",
    fingerprint: {
      schemaVersion: 1,
      taskHash: "b".repeat(64),
      harness: {
        kind: "bare",
        provider: "anthropic",
        model: "claude-opus-4-7",
        iterateFrom: "bare/claude-opus-4-7",
        iteration: { kind: "render-png-feedback" },
      },
      openscadVersion: "OpenSCAD",
      promptTemplateHash: "c".repeat(64),
    },
    ...overrides,
  });
}

describe("isBaselineRun", () => {
  it("is true for the provider-default single-shot bare run", () => {
    expect(isBaselineRun(fakeMeta())).toBe(true);
  });
  it("is false for an explicit effort variant (bare-high/...)", () => {
    expect(isBaselineRun(fakeMeta({ matrixId: "bare-high/claude-opus-4-7" }))).toBe(
      false,
    );
  });
  it("is false for a multi-segment thinking variant (bare-think-off/...)", () => {
    // Regression: the old `^bare-([a-z0-9]+)$` check let two-segment heads
    // like bare-think-off / bare-think-adaptive leak into the baseline.
    expect(
      isBaselineRun(fakeMeta({ matrixId: "bare-think-off/claude-opus-4-7" })),
    ).toBe(false);
    expect(
      isBaselineRun(fakeMeta({ matrixId: "bare-think-adaptive/claude-opus-4-7" })),
    ).toBe(false);
  });
  it("is false for an iter chain step", () => {
    expect(isBaselineRun(iterMeta())).toBe(false);
  });
  it("is false for external-agent runs", () => {
    expect(
      isBaselineRun(
        fakeMeta({
          matrixId: "external-agent/claude-code",
          harness: { kind: "external-agent", agent: "claude-code" } as RunMeta["harness"],
        }),
      ),
    ).toBe(false);
  });
});

describe("buildLeaderboard", () => {
  const tasks = [task("tier-1-a", 1), task("tier-2-b", 2)];

  it("emits canonical task order (tier asc, id asc) shared by every row", () => {
    const lb = buildLeaderboard([fakeRun()], tasks);
    expect(lb.tasks.map((t) => t.id)).toEqual(["tier-1-a", "tier-2-b"]);
  });

  it("groups runs by model and aligns cells to the task order", () => {
    const lb = buildLeaderboard(
      [
        fakeRun({ runId: "1", taskId: "tier-1-a" }),
        fakeRun({ runId: "2", taskId: "tier-2-b" }),
      ],
      tasks,
    );
    expect(lb.rows).toHaveLength(1);
    const row = lb.rows[0]!;
    expect(row.model).toBe("claude-opus-4-7");
    expect(row.cells.map((c) => c.run?.meta.runId ?? null)).toEqual(["1", "2"]);
  });

  it("computes success rate over attempted baseline tasks", () => {
    const lb = buildLeaderboard(
      [
        fakeRun({ runId: "1", taskId: "tier-1-a", status: "success" }),
        fakeRun({ runId: "2", taskId: "tier-2-b", status: "render_error" }),
      ],
      tasks,
    );
    const row = lb.rows[0]!;
    expect(row.tasksAttempted).toBe(2);
    expect(row.successCount).toBe(1);
    expect(row.successRate).toBeCloseTo(0.5);
  });

  it("averages latency and cost over baseline runs", () => {
    const lb = buildLeaderboard(
      [
        fakeRun({ runId: "1", taskId: "tier-1-a", timing: { totalMs: 1000 }, cost_usd: 0.01 }),
        fakeRun({ runId: "2", taskId: "tier-2-b", timing: { totalMs: 3000 }, cost_usd: 0.03 }),
      ],
      tasks,
    );
    const row = lb.rows[0]!;
    expect(row.avgLatencyMs).toBe(2000);
    expect(row.avgCostUsd).toBeCloseTo(0.02);
    expect(row.totalCostUsd).toBeCloseTo(0.04);
  });

  it("ignores non-baseline runs in metrics but counts them in totalRuns", () => {
    const lb = buildLeaderboard(
      [
        fakeRun({ runId: "1", taskId: "tier-1-a", status: "success" }),
        // effort variant + iter step should not affect success rate
        fakeRun({ runId: "2", taskId: "tier-1-a", matrixId: "bare-high/claude-opus-4-7", status: "render_error" }),
        { meta: iterMeta({ runId: "3", taskId: "tier-1-a", status: "render_error" }), scadUrl: "/x" },
      ],
      tasks,
    );
    const row = lb.rows[0]!;
    expect(row.tasksAttempted).toBe(1);
    expect(row.successCount).toBe(1);
    expect(row.successRate).toBe(1);
    expect(row.totalRuns).toBe(3);
  });

  it("keeps the newest baseline run per (model, task)", () => {
    const lb = buildLeaderboard(
      [
        fakeRun({ runId: "old", taskId: "tier-1-a", createdAt: "2026-01-01T00:00:00.000Z", status: "render_error" }),
        fakeRun({ runId: "new", taskId: "tier-1-a", createdAt: "2026-05-01T00:00:00.000Z", status: "success" }),
      ],
      tasks,
    );
    const row = lb.rows[0]!;
    expect(row.cells[0]!.run?.meta.runId).toBe("new");
    expect(row.successCount).toBe(1);
  });

  it("leaves a null cell for a task the model never attempted", () => {
    const lb = buildLeaderboard([fakeRun({ taskId: "tier-1-a" })], tasks);
    const row = lb.rows[0]!;
    expect(row.cells[0]!.run).not.toBeNull();
    expect(row.cells[1]!.run).toBeNull();
    expect(row.cells[1]!.status).toBeNull();
  });

  it("excludes pdf_source tasks from the task axis (bare runs are never scheduled for them)", () => {
    const visionTask: Task = {
      id: "tier-4-v",
      tier: 4,
      title: "Vision",
      prompt: "p",
      pdf_source: { url: "https://example.com/x.pdf", pages: [2] },
    };
    const lb = buildLeaderboard(
      [fakeRun({ taskId: "tier-1-a" })],
      [task("tier-1-a", 1), visionTask],
    );
    expect(lb.tasks.map((t) => t.id)).toEqual(["tier-1-a"]);
    const row = lb.rows[0]!;
    // denominator counts only bare-eligible tasks
    expect(row.cells).toHaveLength(1);
    expect(row.tasksAttempted).toBe(1);
  });

  it("sorts rows by success rate desc by default", () => {
    const lb = buildLeaderboard(
      [
        fakeRun({ runId: "a1", model: "claude-haiku-4-5", taskId: "tier-1-a", status: "success" }),
        fakeRun({ runId: "a2", model: "claude-haiku-4-5", taskId: "tier-2-b", status: "success" }),
        fakeRun({ runId: "b1", model: "gpt-5-2025-08-07", provider: "openai", taskId: "tier-1-a", status: "render_error" }),
      ],
      tasks,
    );
    expect(lb.rows.map((r) => r.model)).toEqual([
      "claude-haiku-4-5",
      "gpt-5-2025-08-07",
    ]);
  });
});
