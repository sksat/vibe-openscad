import type { Candidate } from "./matrix.js";
import type { ResultsIndex } from "./results.js";
import type {
  BenchConfig,
  Fingerprint,
  MatrixEntry,
  RunMeta,
  RunStatus,
} from "./schema.js";

export type PlanStatus = "up-to-date" | "missing" | "stale" | "blocked";

/**
 * Statuses that count as a real "sample" of the model's output for this
 * (task, matrix) combo. Transient failures don't count — we want to retry
 * those automatically, otherwise a missing API key gets cached as
 * up-to-date.
 */
const SAMPLE_STATUSES: ReadonlySet<RunStatus> = new Set<RunStatus>([
  "success",
  "no_code",
  "render_error",
  "submit_missing",
]);

/**
 * Statuses whose artifacts can be fed forward as a chain step's parent
 * (`final.scad` exists). Mirrors `findLatestUsableParentRun` in run.ts —
 * keep in sync.
 */
const USABLE_PARENT_STATUSES: ReadonlySet<RunStatus> = new Set<RunStatus>([
  "success",
  "render_error",
]);

export interface PlanItem {
  candidate: Candidate;
  fingerprint: Fingerprint;
  signature: string;
  status: PlanStatus;
  /** Same-(task,matrix) runs whose signature matches the current one. */
  matchingRuns: RunMeta[];
  /** Same-(task,matrix) runs with a non-matching signature. */
  staleRuns: RunMeta[];
}

export interface PlanInputs {
  cfg: BenchConfig;
  candidates: Candidate[];
  existing: ResultsIndex;
  computeFingerprint: (c: Candidate) => Fingerprint;
  computeSignature: (fp: Fingerprint) => string;
}

/**
 * For an iter-step candidate, walk up its `iterateFrom` chain and decide
 * whether the chain is provably broken (= some ancestor matrixId has runs
 * but none usable as a parent). When true, the candidate would chain-break
 * at run time, so plan reports it as "blocked" rather than "missing".
 *
 * If we can't decide (no runs at any ancestor level, or matrix entry not
 * found), return false — keep it "missing" so it gets a chance.
 */
function isChainBlocked(
  candidate: Candidate,
  byMatrixId: Map<string, MatrixEntry>,
  existing: ResultsIndex,
): boolean {
  const taskId = candidate.task.id;
  const seen = new Set<string>();
  let cur: MatrixEntry = candidate.entry;
  // Walk up while we're on an iter step.
  while (
    cur.harness.kind === "bare" &&
    cur.harness.iterateFrom &&
    !seen.has(cur.id)
  ) {
    seen.add(cur.id);
    const parentId = cur.harness.iterateFrom;
    const parentEntry = byMatrixId.get(parentId);
    if (!parentEntry) return false; // unknown — give up, not blocked
    const parentRuns = existing.all.filter(
      (r) => r.taskId === taskId && r.matrixId === parentId,
    );
    if (parentRuns.length > 0) {
      // Has runs — decide based on whether any are usable.
      const usable = parentRuns.some((r) =>
        USABLE_PARENT_STATUSES.has(r.status),
      );
      return !usable;
    }
    // No runs at this level; if the parent is itself an iter step, walk
    // further (the chain may still be transitively blocked upstream).
    cur = parentEntry;
  }
  return false;
}

export function planRuns(inputs: PlanInputs): PlanItem[] {
  const { cfg, candidates, existing, computeFingerprint, computeSignature } =
    inputs;
  const required = cfg.defaults.samples;
  const items: PlanItem[] = [];

  // Index matrix entries by id for chain-walk lookups.
  const byMatrixId = new Map<string, MatrixEntry>();
  for (const entry of cfg.matrix) byMatrixId.set(entry.id, entry);

  for (const candidate of candidates) {
    const fp = computeFingerprint(candidate);
    const sig = computeSignature(fp);
    const sameScope = existing.all.filter(
      (r) =>
        r.taskId === candidate.task.id && r.matrixId === candidate.entry.id,
    );
    const matching = sameScope.filter((r) => r.signature === sig);
    const stale = sameScope.filter((r) => r.signature !== sig);
    const matchingSamples = matching.filter((r) =>
      SAMPLE_STATUSES.has(r.status),
    );

    let status: PlanStatus;
    if (matchingSamples.length >= required) {
      status = "up-to-date";
    } else if (isChainBlocked(candidate, byMatrixId, existing)) {
      // An upstream parent's only run is unusable — running this would
      // chain-break at runtime. Skip in plan output.
      status = "blocked";
    } else if (matchingSamples.length === 0 && stale.length > 0) {
      status = "stale";
    } else {
      status = "missing";
    }

    items.push({
      candidate,
      fingerprint: fp,
      signature: sig,
      status,
      matchingRuns: matching,
      staleRuns: stale,
    });
  }

  return items;
}
