/**
 * モデルカタログ(`models.yml`)のローダと解決ロジック。
 *
 * 「そのモデルを見れば決まる事実」— 価格 / vision 可否 / provider 既定の
 * reasoning effort / provider 既定の thinking モード / 表示上書き — の
 * 単一情報源。pricing・capabilities・web の表示ロジックはすべてここを引く。
 *
 * キーは **モデル id の prefix** で、解決は **フィールド単位の最長一致**。
 * 短い prefix を「族の既定値」、長い prefix を「個体の上書き」として使える:
 *
 *   gpt-5:      { vision: true, effort: medium, rate: 1.25/10 }
 *   gpt-5.4:    { rate: 2/16 }
 *   → gpt-5.4-2026-03-05 は rate=2/16、vision/effort は gpt-5 から継承
 *
 * `effort: null` のような **明示 null は「軸が無い」という宣言** であり、
 * 未宣言(キーが無い)とは区別する(`"effort" in spec` で判定できる)。
 */
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { parse as parseYaml } from "yaml";
import { z } from "zod";

export const ModelRateSchema = z.object({
  /** USD per 1,000,000 input tokens. */
  in: z.number().nonnegative(),
  /** USD per 1,000,000 output tokens. */
  out: z.number().nonnegative(),
});
export type ModelRateYaml = z.infer<typeof ModelRateSchema>;

export const EffortLevelSchema = z.enum([
  "low",
  "medium",
  "high",
  "xhigh",
  "max",
]);
export type EffortLevel = z.infer<typeof EffortLevelSchema>;

/**
 * thinking 軸の既定値。
 *  - `adaptive`: Claude の adaptive thinking が既定で走る
 *  - `off`: `thinking` 省略時は思考しない(明示 opt-in でのみ on)
 *  - `dynamic`: Gemini の `thinkingBudget: -1`(動的配分)
 */
export const ThinkingModeSchema = z.enum(["adaptive", "off", "dynamic"]);
export type ThinkingMode = z.infer<typeof ThinkingModeSchema>;

/** UI の並び順上書き。省略時は model id から正規表現で導出する。 */
export const ModelSortSchema = z.object({
  /** 族の並び(小さいほど先)。例: Claude なら fable=0 opus=1 sonnet=2。 */
  family: z.number(),
  /** 世代(大きいほど新しい = 先に出る)。 */
  version: z.number(),
  /** 同世代内のサイズ(小さいほど先。pro=-1 base=0 mini=1 nano=2)。 */
  size: z.number().optional(),
});

export const ModelEntrySchema = z
  .object({
    provider: z.string().min(1),
    rate: ModelRateSchema.optional(),
    vision: z.boolean().optional(),
    effort: EffortLevelSchema.nullable().optional(),
    thinking: ThinkingModeSchema.nullable().optional(),
    label: z.string().optional(),
    sort: ModelSortSchema.optional(),
    note: z.string().optional(),
  })
  .strict();
export type ModelEntry = z.infer<typeof ModelEntrySchema>;

export const ModelRegistrySchema = z.record(z.string(), ModelEntrySchema);
export type ModelRegistry = z.infer<typeof ModelRegistrySchema>;

/** 解決済みモデル情報。未宣言フィールドはキーごと存在しない。 */
export type ResolvedModel = ModelEntry;

export function parseModelRegistry(raw: unknown): ModelRegistry {
  const result = ModelRegistrySchema.safeParse(raw);
  if (!result.success) {
    throw new Error(
      `invalid model registry: ${result.error.issues
        .map((i) => `${i.path.join(".")}: ${i.message}`)
        .join("; ")}`,
    );
  }
  return result.data;
}

export function loadModelRegistry(path: string): ModelRegistry {
  const raw = readFileSync(path, "utf8");
  let parsed: unknown;
  try {
    parsed = parseYaml(raw);
  } catch (e) {
    throw new Error(`failed to parse YAML at ${path}: ${(e as Error).message}`);
  }
  return parseModelRegistry(parsed);
}

/**
 * `models.yml` を持つディレクトリまで遡ってリポジトリルートを探す。
 *
 * `import.meta` を使わないのは、web を Astro でビルドすると本モジュールが
 * `web/dist/.prerender/chunks/` へバンドルされて相対パスが dist を指して
 * しまうため(`web/src/lib/dataset.ts` の getDataset と同じ制約)。cwd は
 * bench CLI = リポジトリルート、astro / vitest = パッケージディレクトリ
 * なので、いずれも遡れば当たる。
 */
export function repoRootFrom(start: string): string {
  let dir = start;
  for (let i = 0; i < 10; i++) {
    try {
      readFileSync(join(dir, "models.yml"));
      return dir;
    } catch {
      const parent = dirname(dir);
      if (parent === dir) break;
      dir = parent;
    }
  }
  throw new Error(
    `models.yml not found in any parent directory of ${start}. ` +
      "The model catalog is required to price runs and resolve model metadata.",
  );
}

let cached: ModelRegistry | null = null;

/** リポジトリルートの `models.yml`(プロセス内で 1 度だけ読む)。 */
export function modelRegistry(): ModelRegistry {
  cached ??= loadModelRegistry(join(repoRootFrom(process.cwd()), "models.yml"));
  return cached;
}

/** テスト用: キャッシュを捨てて次回再読み込みさせる。 */
export function resetModelRegistryCache(): void {
  cached = null;
}

/**
 * 指定レジストリからモデルを解決する。prefix が一致するエントリを短い順に
 * 重ねるので、長い prefix が同名フィールドを上書きする。provider を渡すと
 * その provider のエントリだけを見る。
 */
export function resolveModelIn(
  registry: ModelRegistry,
  modelId: string,
  provider?: string,
): ResolvedModel | null {
  const matches = Object.entries(registry)
    .filter(([prefix]) => modelId.startsWith(prefix))
    .filter(([, entry]) => provider === undefined || entry.provider === provider)
    .sort(([a], [b]) => a.length - b.length);
  if (matches.length === 0) return null;
  const merged: Record<string, unknown> = {};
  for (const [, entry] of matches) Object.assign(merged, entry);
  return merged as ResolvedModel;
}

/** リポジトリルートの `models.yml` からモデルを解決する。 */
export function resolveModel(
  modelId: string,
  provider?: string,
): ResolvedModel | null {
  return resolveModelIn(modelRegistry(), modelId, provider);
}
