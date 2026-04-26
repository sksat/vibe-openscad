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
