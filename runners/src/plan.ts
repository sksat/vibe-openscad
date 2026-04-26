import type { Candidate } from "./matrix.js";
import type { ResultsIndex } from "./results.js";
import type {
  BenchConfig,
  Fingerprint,
  RunMeta,
  RunStatus,
} from "./schema.js";

export type PlanStatus = "up-to-date" | "missing" | "stale";

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

export function planRuns(inputs: PlanInputs): PlanItem[] {
  const { cfg, candidates, existing, computeFingerprint, computeSignature } =
    inputs;
  const required = cfg.defaults.samples;
  const items: PlanItem[] = [];

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
