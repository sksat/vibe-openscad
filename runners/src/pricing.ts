/**
 * $/Mtok 価格の参照。価格そのものは `models.yml`(モデルカタログ)側にあり、
 * ここは run のトークン数から USD を出す薄い計算層。
 *
 * プロバイダから公式に取得する API は無いのでカタログは手動更新する。価格
 * 改定があっても過去 run には影響しない(`meta.cost_usd` は実行時に確定して
 * 書き出し済みで、将来 run の計算だけが新価格になる)。
 */
import { resolveModel } from "./models.js";

export interface ModelRate {
  /** USD per 1,000,000 input tokens. */
  inputPerMtok: number;
  /** USD per 1,000,000 output tokens. */
  outputPerMtok: number;
}

export function getRate(provider: string, modelId: string): ModelRate | null {
  const spec = resolveModel(modelId, provider);
  if (!spec?.rate) return null;
  return { inputPerMtok: spec.rate.in, outputPerMtok: spec.rate.out };
}

export function computeCostUsd(
  provider: string,
  modelId: string,
  tokens: { input: number; output: number },
): number | null {
  const rate = getRate(provider, modelId);
  if (!rate) return null;
  const usd =
    (tokens.input / 1_000_000) * rate.inputPerMtok +
    (tokens.output / 1_000_000) * rate.outputPerMtok;
  return usd;
}
