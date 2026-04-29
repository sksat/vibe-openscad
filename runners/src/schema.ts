import { z } from "zod";

const sha256Hex = z.string().regex(/^[0-9a-f]{64}$/);

export const TaskSchema = z.object({
  id: z.string().min(1),
  tier: z.number().int().positive(),
  title: z.string().min(1),
  prompt: z.string().min(1),
  /** URL に使う安定 slug。task の内部 id (`tier-1-mug` 等) は signature
   *  fingerprint に効くので不用意に変えたくない。一方 URL は人間が見るので
   *  tier 番号を排して具体的な名前(`simple-mug`, `oriented-handle-mug` 等)
   *  にしたい。両者を両立させるため slug を別フィールドにする。
   *  optional で、未指定時は id をそのまま slug として使う(下位互換)。 */
  slug: z.string().min(1).regex(/^[a-z0-9][a-z0-9-]*$/).optional(),
  /**
   * 入力画像のパス(YAML ファイルからの相対)。データシートや製図画像を
   * モデルに見せて 3D を起こさせる類の vision タスクで使う。
   * 指定があると vision 非対応モデルでは plan 段階で skip される。
   * 画像内容は taskHash に `prompt_image_hashes` として入る(画像差し替え
   * = 別タスク扱いで再 run トリガ)。
   */
  prompt_images: z.array(z.string().min(1)).optional(),
  /**
   * Loader が `prompt_images` を読んで sha256 を埋める。fingerprint の
   * 安定性は path ではなく content 側で取りたいので、computeTaskHash は
   * `prompt_images`(path)を除外し `prompt_image_hashes`(中身)を含める。
   * YAML 側で書く必要は無い(loader が上書きする)。
   */
  prompt_image_hashes: z.array(z.string()).optional(),
  /**
   * Loader が読んだ画像バイト列。harness 実行時に provider に投げるため。
   * canonicalJson に流れると壊れるので computeTaskHash では除外する。
   */
  prompt_image_data: z.array(z.instanceof(Buffer)).optional(),
  /**
   * PDF の指定ページを画像として入力に使うタイプの task(データシート
   * 起こし等)向け。`pdf-page` harness が読んで pdftoppm で PNG に変換
   * してから provider に投げる。`prompt_images` と排他に使う想定だが
   * 同居も妨げない(harness 側でマージして送る)。
   */
  pdf_source: z
    .object({
      url: z.string().url(),
      pages: z.array(z.number().int().positive()).min(1),
    })
    .optional(),
  /**
   * Loader が PDF を取りに行ったときに content sha256 を埋める。
   * fingerprint(taskHash)はこれを含める = PDF が差し替わったら再 run。
   * URL は環境依存なので除外し、中身ベースで stable にする。
   */
  pdf_source_hash: z.string().optional(),
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
 * `bare` と同形だが、task 側 `pdf_source` を読んで PDF の指定ページを
 * 画像として provider に渡す preprocessing が前段に入る。tier-4 の
 * 「データシート画像から 3D 起こし」系タスクで使う。
 *
 * iter チェーン(iterateFrom / iteration)も同じ意味で使える。ただし
 * 親の出力(SCAD/PNG)は通常 iter-png-feedback と同じ流れなので、
 * pdf-page の iter 子は通常 `bare` または `pdf-page` どちらの親でも
 * よい(PDF を再投入する必要は無い)。
 */
const PdfPageHarnessConfigSchema = z.object({
  kind: z.literal("pdf-page"),
  iterateFrom: z.string().min(1).optional(),
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

const MatrixEntryPdfPageSchema = z.object({
  id: z.string().min(1),
  harness: PdfPageHarnessConfigSchema,
  provider: z.string().min(1),
  model: z.string().min(1),
  modelOptions: z.record(z.string(), z.unknown()).optional(),
  revision: z.string().optional(),
});

const MatrixEntryExternalAgentSchema = z.object({
  id: z.string().min(1),
  harness: ExternalAgentHarnessConfigSchema,
  modelHint: z.string().optional(),
});

const MatrixEntrySchema = z.union([
  MatrixEntryBareSchema,
  MatrixEntryPdfPageSchema,
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
        /**
         * 並列実行の設定。bench は API 待ちで blocking する時間が
         * 大半なので、並列化が時間短縮にすごく効く。
         *
         * デフォルト方針:
         * - global=4: 4 並列。これくらいなら大抵の rate limit 内に収まる
         * - perProvider.anthropic=2: Anthropic は他社より rate limit が
         *   厳しめ(tier 1 で 50 req/min、ITPM/OTPM もタイト)なので 2 並列
         *   に絞る。他 provider は global と同じ枠で走らせる
         *
         * 直列にしたい場合は CLI で `-j 1`、または bench-config.yml で
         * 上書きする。
         */
        concurrency: z
          .object({
            /** 同時実行できる候補の最大数(全 provider 合計)。 */
            global: z.number().int().positive().default(4),
            /** provider 別の上限。rate limit が provider ごとに違うので
             *  個別に締めたい場合に使う(例: anthropic=2, openai=4)。
             *  指定無し provider は Infinity 扱い。 */
            perProvider: z
              .record(z.string(), z.number().int().positive())
              .default({ anthropic: 2 }),
          })
          .default({ global: 4, perProvider: { anthropic: 2 } }),
      })
      .default({
        samples: 1,
        timeoutSec: 300,
        concurrency: { global: 4, perProvider: { anthropic: 2 } },
      }),
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

const FingerprintPdfPageHarnessSchema = z.object({
  kind: z.literal("pdf-page"),
  provider: z.string().min(1),
  model: z.string().min(1),
  modelOptions: z.record(z.string(), z.unknown()).optional(),
  revision: z.string().optional(),
  iterateFrom: z.string().min(1).optional(),
  iteration: IterationStrategySchema.optional(),
  parentSignature: sha256Hex.optional(),
});

export const FingerprintSchema = z.object({
  schemaVersion: z.literal(1),
  taskHash: sha256Hex,
  harness: z.discriminatedUnion("kind", [
    FingerprintBareHarnessSchema,
    FingerprintPdfPageHarnessSchema,
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

/**
 * セルフホスト LLM のモデル個体メタデータ。`provider: openai-self-hosted`
 * が run 時に host を叩いて埋める(LM Studio /api/v0/models, Ollama
 * /api/tags 等)。クラウド provider では omit。
 *
 * publisher / quantization が違うと挙動も変わるので、後で再現性を
 * 追えるよう meta.json に同梱しておく。
 */
/** Self-hosted ランタイムを動かしているホスト機のハードウェア情報。
 *  LM Studio から runtime 取得した値を入れる。**hostname は含めない**。 */
export const HostInfoSchema = z.object({
  gpu: z.string().optional(),
  vramGb: z.number().positive().optional(),
  gpuPlatform: z.string().optional(),
  cpu: z.string().optional(),
  memGb: z.number().positive().optional(),
});
export type HostInfo = z.infer<typeof HostInfoSchema>;

const ModelMetadataSchema = z.object({
  publisher: z.string().optional(),
  type: z.string().optional(),
  arch: z.string().optional(),
  quantization: z.string().optional(),
  maxContextLength: z.number().optional(),
  capabilities: z.array(z.string()).optional(),
  parameterSize: z.string().optional(),
  size: z.number().optional(),
  host: HostInfoSchema.optional(),
  raw: z.record(z.string(), z.unknown()).optional(),
});

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
    modelMetadata: ModelMetadataSchema.optional(),
  }),
  z.object({
    kind: z.literal("pdf-page"),
    iteration: IterationStrategySchema.optional(),
    iterationsRun: z.number().int().nonnegative().optional(),
    /** PDF を取得した URL(参考用、再現性は taskHash の hash 側で担保)。 */
    pdfUrl: z.string().optional(),
    /** 切り出したページ番号(参考用)。 */
    pages: z.array(z.number().int().positive()).optional(),
    modelMetadata: ModelMetadataSchema.optional(),
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
    /** Wallclock の総実行時間。プロンプト送信〜レスポンス受信完了まで。
     *  ロード/プロンプト評価/生成/ネットワークすべてを含む。 */
    totalMs: z.number().nonnegative(),
    /** First token までの時間(ms)。LM Studio 等が応答に含めるとき記録。 */
    firstTokenMs: z.number().nonnegative().optional(),
    /** 純粋な生成時間(ms、ロード・プロンプト評価を除く)。LM Studio
     *  `stats.generation_time` を ms に変換したもの。token/sec の計算で
     *  wallclock と分けて見たいときに使う。 */
    generationMs: z.number().nonnegative().optional(),
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
