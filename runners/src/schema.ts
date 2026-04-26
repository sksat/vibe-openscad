import { z } from "zod";

const sha256Hex = z.string().regex(/^[0-9a-f]{64}$/);

export const TaskSchema = z.object({
  id: z.string().min(1),
  tier: z.number().int().positive(),
  title: z.string().min(1),
  prompt: z.string().min(1),
});
export type Task = z.infer<typeof TaskSchema>;

const BareHarnessConfigSchema = z.object({
  kind: z.literal("bare"),
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

/**
 * One step in an agentic harness's render-and-fix loop. The final iteration
 * of a run also serves as the run's `final.{scad,stl,png}`. For bare (single
 * shot) runs `iterations` is omitted entirely.
 */
const IterationMetaSchema = z.object({
  /** 1-based position within the run. */
  index: z.number().int().positive(),
  /** Status of this iteration on its own. */
  status: z.enum(["success", "render_error", "no_code"]),
  /** Free-form description (e.g. feedback the agent received before this step). */
  note: z.string().optional(),
  /** Render or compile error message, if any. */
  error: z.string().optional(),
  /** Wall-clock for this iteration only. */
  durationMs: z.number().nonnegative(),
  /** Tokens spent on this iteration only. */
  tokens: z
    .object({
      input: z.number().int().nonnegative(),
      output: z.number().int().nonnegative(),
    })
    .optional(),
  cost_usd: z.number().nonnegative().optional(),
  /** sha256 of the iteration's SCAD source, for dedup / change detection. */
  scadSha256: z
    .string()
    .regex(/^[0-9a-f]{64}$/)
    .optional(),
});
export type IterationMeta = z.infer<typeof IterationMetaSchema>;

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
  z.object({ kind: z.literal("bare") }),
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
   * Per-iteration history for agentic harnesses. The last iteration is the
   * one that produced `final.{scad,stl,png}`. Bare (single-shot) runs omit
   * this field entirely.
   */
  iterations: z.array(IterationMetaSchema).optional(),
});
export type RunMeta = z.infer<typeof RunMetaSchema>;
