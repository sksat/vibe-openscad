import { describe, expect, it } from "vitest";
import { type Candidate } from "./matrix.js";
import { type PlanInputs, planRuns } from "./plan.js";
import type { BenchConfig, Fingerprint, RunMeta, Task } from "./schema.js";

const task: Task = { id: "tier-1-cube", tier: 1, title: "Cube", prompt: "p" };

const cfg: BenchConfig = {
  defaults: { samples: 1, timeoutSec: 300 },
  matrix: [
    {
      id: "claude-bare",
      harness: { kind: "bare" },
      provider: "anthropic",
      model: "claude-opus-4-7",
    },
  ],
  tasks: [{ tier: 1 }],
};

const candidate: Candidate = {
  task,
  entry: cfg.matrix[0]!,
};

const fingerprint: Fingerprint = {
  schemaVersion: 1,
  taskHash: "a".repeat(64),
  harness: {
    kind: "bare",
    provider: "anthropic",
    model: "claude-opus-4-7",
  },
  openscadVersion: "OpenSCAD 2021.01",
  promptTemplateHash: "b".repeat(64),
};

const SIG_CURRENT = "c".repeat(64);
const SIG_OLD = "d".repeat(64);

const baseRun: RunMeta = {
  runId: "run-1",
  taskId: task.id,
  matrixId: "claude-bare",
  signature: SIG_CURRENT,
  fingerprint,
  provider: "anthropic",
  model: "claude-opus-4-7",
  harness: { kind: "bare" },
  status: "success",
  timing: { totalMs: 100 },
  createdAt: "2026-04-27T00:00:00Z",
};

function inputs(overrides: Partial<PlanInputs>): PlanInputs {
  return {
    cfg,
    candidates: [candidate],
    existing: { all: [], bySignature: new Map() },
    computeFingerprint: () => fingerprint,
    computeSignature: () => SIG_CURRENT,
    ...overrides,
  };
}

describe("planRuns", () => {
  it("classifies a candidate with no existing run as missing", () => {
    const plan = planRuns(inputs({}));
    expect(plan).toHaveLength(1);
    expect(plan[0]?.status).toBe("missing");
  });

  it("classifies a candidate with a matching signature as up-to-date", () => {
    const plan = planRuns(
      inputs({
        existing: {
          all: [baseRun],
          bySignature: new Map([[SIG_CURRENT, [baseRun]]]),
        },
      }),
    );
    expect(plan[0]?.status).toBe("up-to-date");
    expect(plan[0]?.matchingRuns).toEqual([baseRun]);
  });

  it("classifies as stale when an old run exists for same (task, matrixId) but signature differs", () => {
    const oldRun: RunMeta = { ...baseRun, signature: SIG_OLD };
    const plan = planRuns(
      inputs({
        existing: {
          all: [oldRun],
          bySignature: new Map([[SIG_OLD, [oldRun]]]),
        },
      }),
    );
    expect(plan[0]?.status).toBe("stale");
    expect(plan[0]?.staleRuns).toEqual([oldRun]);
  });

  it("treats samples shortage as missing", () => {
    const cfg2: BenchConfig = {
      ...cfg,
      defaults: { samples: 3, timeoutSec: 300 },
    };
    const plan = planRuns(
      inputs({
        cfg: cfg2,
        existing: {
          all: [baseRun],
          bySignature: new Map([[SIG_CURRENT, [baseRun]]]),
        },
      }),
    );
    expect(plan[0]?.status).toBe("missing");
    expect(plan[0]?.matchingRuns).toEqual([baseRun]);
  });

  it("ignores existing runs from a different matrixId", () => {
    const otherRun: RunMeta = {
      ...baseRun,
      matrixId: "different-matrix-id",
      signature: SIG_OLD,
    };
    const plan = planRuns(
      inputs({
        existing: {
          all: [otherRun],
          bySignature: new Map([[SIG_OLD, [otherRun]]]),
        },
      }),
    );
    expect(plan[0]?.status).toBe("missing");
    expect(plan[0]?.staleRuns).toEqual([]);
  });

  it("does not count api_error or timeout runs toward samples", () => {
    const apiErrorRun: RunMeta = {
      ...baseRun,
      status: "api_error",
      runId: "api-err-run",
    };
    const plan = planRuns(
      inputs({
        existing: {
          all: [apiErrorRun],
          bySignature: new Map([[SIG_CURRENT, [apiErrorRun]]]),
        },
      }),
    );
    expect(plan[0]?.status).toBe("missing");
  });

  it("treats no_code and render_error as legitimate samples", () => {
    const noCodeRun: RunMeta = {
      ...baseRun,
      status: "no_code",
      runId: "no-code-run",
    };
    const plan = planRuns(
      inputs({
        existing: {
          all: [noCodeRun],
          bySignature: new Map([[SIG_CURRENT, [noCodeRun]]]),
        },
      }),
    );
    expect(plan[0]?.status).toBe("up-to-date");
  });

  it("classifies an iter step as blocked when its parent's only run is no_code", () => {
    const parentEntry = cfg.matrix[0]!;
    const iterEntry = {
      id: "iter-1",
      harness: {
        kind: "bare" as const,
        iterateFrom: parentEntry.id,
        iteration: { kind: "render-png-feedback" as const },
      },
      provider: "anthropic",
      model: "claude-opus-4-7",
    };
    const cfg2: BenchConfig = {
      ...cfg,
      matrix: [parentEntry, iterEntry],
    };
    const noCodeParent: RunMeta = {
      ...baseRun,
      runId: "parent-no-code",
      status: "no_code",
    };
    const iterCandidate: Candidate = { task, entry: iterEntry };
    const plan = planRuns(
      inputs({
        cfg: cfg2,
        candidates: [{ task, entry: parentEntry }, iterCandidate],
        existing: {
          all: [noCodeParent],
          bySignature: new Map([[SIG_CURRENT, [noCodeParent]]]),
        },
      }),
    );
    const iterPlan = plan.find((p) => p.candidate.entry.id === "iter-1");
    expect(iterPlan?.status).toBe("blocked");
  });

  it("classifies an iter step as missing when its parent has a usable run (success)", () => {
    const parentEntry = cfg.matrix[0]!;
    const iterEntry = {
      id: "iter-1",
      harness: {
        kind: "bare" as const,
        iterateFrom: parentEntry.id,
        iteration: { kind: "render-png-feedback" as const },
      },
      provider: "anthropic",
      model: "claude-opus-4-7",
    };
    const cfg2: BenchConfig = {
      ...cfg,
      matrix: [parentEntry, iterEntry],
    };
    const iterCandidate: Candidate = { task, entry: iterEntry };
    // baseRun is status=success on parent matrixId.
    const plan = planRuns(
      inputs({
        cfg: cfg2,
        candidates: [{ task, entry: parentEntry }, iterCandidate],
        existing: {
          all: [baseRun],
          bySignature: new Map([[SIG_CURRENT, [baseRun]]]),
        },
      }),
    );
    const iterPlan = plan.find((p) => p.candidate.entry.id === "iter-1");
    expect(iterPlan?.status).toBe("missing");
  });

  it("classifies an iter step as missing (not blocked) when parent has no runs yet", () => {
    // Parent hasn't been run; we can't know the outcome, so mark missing
    // (the parent will be tried in this same run and could succeed).
    const parentEntry = cfg.matrix[0]!;
    const iterEntry = {
      id: "iter-1",
      harness: {
        kind: "bare" as const,
        iterateFrom: parentEntry.id,
        iteration: { kind: "render-png-feedback" as const },
      },
      provider: "anthropic",
      model: "claude-opus-4-7",
    };
    const cfg2: BenchConfig = {
      ...cfg,
      matrix: [parentEntry, iterEntry],
    };
    const iterCandidate: Candidate = { task, entry: iterEntry };
    const plan = planRuns(
      inputs({
        cfg: cfg2,
        candidates: [{ task, entry: parentEntry }, iterCandidate],
        existing: { all: [], bySignature: new Map() },
      }),
    );
    const iterPlan = plan.find((p) => p.candidate.entry.id === "iter-1");
    expect(iterPlan?.status).toBe("missing");
  });

  it("propagates blocked through transitive chain when an upstream is no_code", () => {
    // bare → iter-1 (no_code) → iter-2 (no run) → iter-3
    // iter-2 should be blocked (parent's only run is no_code) AND iter-3
    // should be blocked too (transitive: iter-2 has no run, but its parent
    // iter-1 is unusable, so the whole chain is dead).
    const parentEntry = cfg.matrix[0]!;
    const iter1Entry = {
      id: "iter-1",
      harness: {
        kind: "bare" as const,
        iterateFrom: parentEntry.id,
        iteration: { kind: "render-png-feedback" as const },
      },
      provider: "anthropic",
      model: "claude-opus-4-7",
    };
    const iter2Entry = {
      id: "iter-2",
      harness: {
        kind: "bare" as const,
        iterateFrom: "iter-1",
        iteration: { kind: "render-png-feedback" as const },
      },
      provider: "anthropic",
      model: "claude-opus-4-7",
    };
    const iter3Entry = {
      id: "iter-3",
      harness: {
        kind: "bare" as const,
        iterateFrom: "iter-2",
        iteration: { kind: "render-png-feedback" as const },
      },
      provider: "anthropic",
      model: "claude-opus-4-7",
    };
    const cfg2: BenchConfig = {
      ...cfg,
      matrix: [parentEntry, iter1Entry, iter2Entry, iter3Entry],
    };
    const noCodeIter1: RunMeta = {
      ...baseRun,
      matrixId: "iter-1",
      runId: "iter-1-no-code",
      status: "no_code",
    };
    const plan = planRuns(
      inputs({
        cfg: cfg2,
        candidates: [
          { task, entry: parentEntry },
          { task, entry: iter1Entry },
          { task, entry: iter2Entry },
          { task, entry: iter3Entry },
        ],
        existing: {
          all: [noCodeIter1],
          bySignature: new Map([[SIG_CURRENT, [noCodeIter1]]]),
        },
      }),
    );
    expect(plan.find((p) => p.candidate.entry.id === "iter-2")?.status).toBe(
      "blocked",
    );
    expect(plan.find((p) => p.candidate.entry.id === "iter-3")?.status).toBe(
      "blocked",
    );
  });

  it("counts only same-task same-matrix runs toward samples and stale lists", () => {
    const sameTaskOtherSig: RunMeta = {
      ...baseRun,
      runId: "old-run",
      signature: SIG_OLD,
    };
    const plan = planRuns(
      inputs({
        existing: {
          all: [sameTaskOtherSig, baseRun],
          bySignature: new Map([
            [SIG_CURRENT, [baseRun]],
            [SIG_OLD, [sameTaskOtherSig]],
          ]),
        },
      }),
    );
    expect(plan[0]?.status).toBe("up-to-date");
    expect(plan[0]?.staleRuns).toEqual([sameTaskOtherSig]);
  });
});
