import { z } from "zod";

const sha256Hex = z.string().regex(/^[0-9a-f]{64}$/);

export const TaskSchema = z.object({
  id: z.string().min(1),
  tier: z.number().int().positive(),
  title: z.string().min(1),
  prompt: z.string().min(1),
});
export type Task = z.infer<typeof TaskSchema>;

/**
 * Iteration strategy — describes how a *single* iteration step builds its
 * feedback turn from the predecessor run's artifacts. Each iteration step
 * is its own benchmark run (one LLM call); chains are expressed as separate
 * matrix entries linked via `iterateFrom`, not as a count inside one entry.
 * That way iter-1, iter-2, iter-3 are first-class runs and multiple
 * strategies can branch off the same iter-1 without re-running it.
 *
 * Discriminated union so new strategies (multi-angle PNGs, cost-budget,
 * verifier-sub-model, etc.) can be added as new variants without
 * perturbing existing entries' fingerprints.
 */
const IterationStrategySchema = z.discriminatedUnion("kind", [
  z.object({
    kind: z.literal("render-png-feedback"),
    /** Optional override for the feedback message text. */
    promptOverride: z.string().optional(),
  }),
  z.object({
    kind: z.literal("error-text-feedback"),
    promptOverride: z.string().optional(),
  }),
]);
export type IterationStrategy = z.infer<typeof IterationStrategySchema>;

/**
 * Bare provider call. Single-shot when both `iterateFrom` and `iteration`
 * are omitted — same fingerprint shape as pre-iteration runs.
 *
 * When `iterateFrom` is set, this entry is **one iteration step** that
 * depends on a predecessor matrix entry's successful run for the same
 * task. The harness reads the predecessor's `final.scad`/`final.png`,
 * builds a feedback turn with `iteration`, and makes one LLM call.
 * Each step is its own first-class benchmark run with `parentRunId`
 * pointing back at the predecessor — so iter-1, iter-2, iter-3 are
 * three separate runs, and multiple iteration strategies can branch
 * from the same iter-1 without re-running it.
 */
const BareHarnessConfigSchema = z.object({
  kind: z.literal("bare"),
  /** Matrix id of the predecessor (the run whose output we iterate on). */
  iterateFrom: z.string().min(1).optional(),
  /** Strategy for the feedback turn (required when iterateFrom is set). */
  iteration: IterationStrategySchema.optional(),
});

/**
 * Sub-agent declared on an external-agent harness — e.g. a separate
 * verifier or critic that reviews render output. May use a different
 * model from the main agent. Part of the fingerprint so swapping it
 * invalidates the cache.
 */
const SubagentConfigSchema = z.object({
  name: z.string().min(1),
  /** Provider, if the sub-agent is a bare LLM call. Omit for built-in agents. */
  provider: z.string().optional(),
  /** Model the sub-agent runs on. */
  model: z.string().min(1),
  /** Free-form role tag, e.g. "verifier", "render_reviewer". */
  role: z.string().optional(),
});
export type SubagentConfig = z.infer<typeof SubagentConfigSchema>;

const ExternalAgentHarnessConfigSchema = z.object({
  kind: z.literal("external-agent"),
  agent: z.string().min(1),
  maxTurns: z.number().int().positive(),
  allowedTools: z.array(z.string()).optional(),
  subagents: z.array(SubagentConfigSchema).optional(),
});

const MatrixEntryBareSchema = z.object({
  id: z.string().min(1),
  harness: BareHarnessConfigSchema,
  provider: z.string().min(1),
  model: z.string().min(1),
  modelOptions: z.record(z.string(), z.unknown()).optional(),
  /**
   * Optional user-assigned cache-busting tag. Bump when you suspect a
   * silent provider-side update to a model alias whose response shape
   * doesn't expose the underlying snapshot.
   */
  revision: z.string().optional(),
});

const MatrixEntryExternalAgentSchema = z.object({
  id: z.string().min(1),
  harness: ExternalAgentHarnessConfigSchema,
  modelHint: z.string().optional(),
});

const MatrixEntrySchema = z.union([
  MatrixEntryBareSchema,
  MatrixEntryExternalAgentSchema,
]);
export type MatrixEntry = z.infer<typeof MatrixEntrySchema>;

const TaskSelectorSchema = z.union([
  z.object({ tier: z.number().int().positive() }),
  z.object({ id: z.string().min(1) }),
]);
export type TaskSelector = z.infer<typeof TaskSelectorSchema>;

export const BenchConfigSchema = z
  .object({
    defaults: z
      .object({
        samples: z.number().int().positive().default(1),
        timeoutSec: z.number().int().positive().default(300),
      })
      .default({ samples: 1, timeoutSec: 300 }),
    matrix: z.array(MatrixEntrySchema).min(1),
    tasks: z.array(TaskSelectorSchema).min(1),
  })
  .superRefine((cfg, ctx) => {
    const seen = new Set<string>();
    for (const entry of cfg.matrix) {
      if (seen.has(entry.id)) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["matrix"],
          message: `duplicate matrix id: ${entry.id}`,
        });
      }
      seen.add(entry.id);
    }
  });
export type BenchConfig = z.infer<typeof BenchConfigSchema>;

const FingerprintBareHarnessSchema = z.object({
  kind: z.literal("bare"),
  provider: z.string().min(1),
  model: z.string().min(1),
  modelOptions: z.record(z.string(), z.unknown()).optional(),
  /** User-assigned cache-busting tag (see MatrixEntryBareSchema.revision). */
  revision: z.string().optional(),
  /** Predecessor matrix id (only set on iteration steps). */
  iterateFrom: z.string().min(1).optional(),
  /**
   * Iteration strategy fingerprint. Omitted for single-shot bare runs
   * (signature-compatible with pre-iteration data). Required on
   * iteration steps.
   */
  iteration: IterationStrategySchema.optional(),
  /**
   * Predecessor's signature, embedded so changing the parent (e.g. swapping
   * its model) cascades to the child's signature and re-stales it. Set iff
   * `iterateFrom` is set.
   */
  parentSignature: sha256Hex.optional(),
});

const FingerprintExternalAgentHarnessSchema = z.object({
  kind: z.literal("external-agent"),
  agent: z.string().min(1),
  agentVersion: z.string().min(1),
  maxTurns: z.number().int().positive(),
  allowedTools: z.array(z.string()),
  modelHint: z.string().optional(),
  /**
   * Sub-agents declared on the harness (e.g. a render verifier on a
   * different model). Part of the fingerprint so swapping any of them
   * invalidates the cache. Order matters — preserve the configured order.
   */
  subagents: z.array(SubagentConfigSchema).optional(),
});

export const FingerprintSchema = z.object({
  schemaVersion: z.literal(1),
  taskHash: sha256Hex,
  harness: z.discriminatedUnion("kind", [
    FingerprintBareHarnessSchema,
    FingerprintExternalAgentHarnessSchema,
  ]),
  mcpServerVersion: z.string().optional(),
  openscadVersion: z.string().min(1),
  promptTemplateHash: sha256Hex,
});
export type Fingerprint = z.infer<typeof FingerprintSchema>;

const RunStatusSchema = z.enum([
  "success",
  "render_error",
  "no_code",
  "submit_missing",
  "timeout",
  "api_error",
]);
export type RunStatus = z.infer<typeof RunStatusSchema>;

const SubagentLogSchema = z.object({
  name: z.string().min(1),
  provider: z.string().optional(),
  model: z.string().min(1),
  role: z.string().optional(),
  invocations: z.number().int().nonnegative(),
  tokens: z
    .object({
      input: z.number().int().nonnegative(),
      output: z.number().int().nonnegative(),
    })
    .optional(),
  cost_usd: z.number().nonnegative().optional(),
});
export type SubagentLog = z.infer<typeof SubagentLogSchema>;

const RunHarnessLogSchema = z.discriminatedUnion("kind", [
  z.object({
    kind: z.literal("bare"),
    /**
     * For iterative bare runs, mirror the iteration strategy + how many
     * rounds actually fired. Omitted for single-shot (back-compat with
     * pre-iteration meta.json files).
     */
    iteration: IterationStrategySchema.optional(),
    iterationsRun: z.number().int().nonnegative().optional(),
  }),
  z.object({
    kind: z.literal("external-agent"),
    agent: z.string().min(1),
    agentVersion: z.string().min(1),
    maxTurns: z.number().int().positive(),
    turnsUsed: z.number().int().nonnegative(),
    renderCalls: z.number().int().nonnegative(),
    /** Per-subagent telemetry, parallel to fingerprint.subagents. */
    subagents: z.array(SubagentLogSchema).optional(),
  }),
]);

export const RunMetaSchema = z.object({
  runId: z.string().min(1),
  taskId: z.string().min(1),
  matrixId: z.string().min(1),
  signature: sha256Hex,
  fingerprint: FingerprintSchema,
  provider: z.string().nullable(),
  model: z.string().nullable(),
  harness: RunHarnessLogSchema,
  status: RunStatusSchema,
  timing: z.object({
    totalMs: z.number().nonnegative(),
    firstTokenMs: z.number().nonnegative().optional(),
  }),
  tokens: z
    .object({
      input: z.number().int().nonnegative(),
      output: z.number().int().nonnegative(),
    })
    .optional(),
  cost_usd: z.number().nonnegative().optional(),
  createdAt: z.string().min(1),
  gitCommit: z.string().optional(),
  /** Free-form error detail when status is non-success. */
  error: z.string().optional(),
  /**
   * For iteration steps: runId of the predecessor whose final.{scad,png}
   * was fed back into this run. Omitted for single-shot bare runs and the
   * head of an iteration chain.
   */
  parentRunId: z.string().min(1).optional(),
});
export type RunMeta = z.infer<typeof RunMetaSchema>;
