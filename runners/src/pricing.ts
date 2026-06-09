/**
 * モデルごとの $/Mtok 価格表。プロバイダから公式に取得する API は無いので
 * 手動で更新する。価格変動があった時は run の `meta.cost_usd` には書き出し
 * 済みなので過去 run には影響しない(将来 run の計算が新価格になる)。
 *
 * 出典: Anthropic 公式ドキュメント(2026-04 時点)。
 */

export interface ModelRate {
  /** USD per 1,000,000 input tokens. */
  inputPerMtok: number;
  /** USD per 1,000,000 output tokens. */
  outputPerMtok: number;
}

interface Entry {
  /** Match against modelId by prefix (so dated snapshots inherit the alias rate). */
  prefix: string;
  rate: ModelRate;
}

const ANTHROPIC_RATES: Entry[] = [
  // 現行
  { prefix: "claude-fable-5", rate: { inputPerMtok: 10, outputPerMtok: 50 } },
  { prefix: "claude-opus-4-8", rate: { inputPerMtok: 5, outputPerMtok: 25 } },
  { prefix: "claude-opus-4-7", rate: { inputPerMtok: 5, outputPerMtok: 25 } },
  { prefix: "claude-opus-4-6", rate: { inputPerMtok: 5, outputPerMtok: 25 } },
  { prefix: "claude-sonnet-4-6", rate: { inputPerMtok: 3, outputPerMtok: 15 } },
  { prefix: "claude-haiku-4-5", rate: { inputPerMtok: 1, outputPerMtok: 5 } },
  // legacy(active)
  { prefix: "claude-opus-4-5", rate: { inputPerMtok: 5, outputPerMtok: 25 } },
  { prefix: "claude-opus-4-1", rate: { inputPerMtok: 15, outputPerMtok: 75 } },
  { prefix: "claude-opus-4-0", rate: { inputPerMtok: 15, outputPerMtok: 75 } },
  { prefix: "claude-opus-4-",  rate: { inputPerMtok: 15, outputPerMtok: 75 } }, // catch-all for snapshot-only ids
  { prefix: "claude-sonnet-4-5", rate: { inputPerMtok: 3, outputPerMtok: 15 } },
  { prefix: "claude-sonnet-4-0", rate: { inputPerMtok: 3, outputPerMtok: 15 } },
  { prefix: "claude-sonnet-4-",  rate: { inputPerMtok: 3, outputPerMtok: 15 } },
  // 古い 3.x(参考)
  { prefix: "claude-3-haiku", rate: { inputPerMtok: 0.25, outputPerMtok: 1.25 } },
];

// Gemini pricing 出典: https://ai.google.dev/pricing (2026-05 時点)
// Gemini 3 (preview) は公式価格未公表のため 2.5 同等で仮置き — 公開され次第更新。
const GOOGLE_RATES: Entry[] = [
  // 3.5 世代(GA、2026-05-19 I/O)
  { prefix: "gemini-3.5-flash", rate: { inputPerMtok: 1.5, outputPerMtok: 9 } },
  // 3 世代(preview、暫定価格)
  { prefix: "gemini-3.1-pro", rate: { inputPerMtok: 1.25, outputPerMtok: 10 } },
  { prefix: "gemini-3-pro", rate: { inputPerMtok: 1.25, outputPerMtok: 10 } },
  { prefix: "gemini-3.1-flash-lite", rate: { inputPerMtok: 0.1, outputPerMtok: 0.4 } },
  { prefix: "gemini-3.1-flash", rate: { inputPerMtok: 0.3, outputPerMtok: 2.5 } },
  { prefix: "gemini-3-flash", rate: { inputPerMtok: 0.3, outputPerMtok: 2.5 } },
  // 2.5 世代(GA)
  { prefix: "gemini-2.5-pro", rate: { inputPerMtok: 1.25, outputPerMtok: 10 } },
  { prefix: "gemini-2.5-flash-lite", rate: { inputPerMtok: 0.1, outputPerMtok: 0.4 } },
  { prefix: "gemini-2.5-flash", rate: { inputPerMtok: 0.3, outputPerMtok: 2.5 } },
  // 1.5 系(legacy)
  { prefix: "gemini-1.5-pro", rate: { inputPerMtok: 1.25, outputPerMtok: 5 } },
  { prefix: "gemini-1.5-flash", rate: { inputPerMtok: 0.075, outputPerMtok: 0.3 } },
];

// OpenAI pricing — 公式ページの web fetch がブロックされたため、これらは
// **未検証の training-data 推定値 + リーダーボードからの逆算**。実勢と数倍
// 違う可能性があるので、cost_usd を比較指標として使う前に必ず
// https://openai.com/api/pricing で実値を確認・更新すること。
//
// プレフィクスマッチで「最長一致が勝つ」(getRate 実装)ので、より具体的な
// バリアント(`-pro` / `-mini` / `-nano`)のエントリは family base より上に
// 並べる。`gpt-5.4-mini-...` のようなモデルは `gpt-5.4-mini` family にマッチ
// すべきで、`gpt-5` base には落とさない。
const OPENAI_RATES: Entry[] = [
  // GPT-5.4 系(2026-03 系の現行)
  { prefix: "gpt-5.4-nano", rate: { inputPerMtok: 0.075, outputPerMtok: 0.6 } },
  { prefix: "gpt-5.4-mini", rate: { inputPerMtok: 0.4, outputPerMtok: 3 } },
  { prefix: "gpt-5.4", rate: { inputPerMtok: 2, outputPerMtok: 16 } },
  // GPT-5.2 系(pro variant あり)
  { prefix: "gpt-5.2-pro", rate: { inputPerMtok: 17, outputPerMtok: 130 } },
  { prefix: "gpt-5.2-nano", rate: { inputPerMtok: 0.06, outputPerMtok: 0.5 } },
  { prefix: "gpt-5.2-mini", rate: { inputPerMtok: 0.3, outputPerMtok: 2.5 } },
  { prefix: "gpt-5.2", rate: { inputPerMtok: 1.6, outputPerMtok: 12 } },
  { prefix: "gpt-5.1", rate: { inputPerMtok: 1.4, outputPerMtok: 11 } },
  { prefix: "gpt-5.3", rate: { inputPerMtok: 1.5, outputPerMtok: 12 } },
  // GPT-5(初期世代)
  { prefix: "gpt-5-pro", rate: { inputPerMtok: 15, outputPerMtok: 120 } },
  { prefix: "gpt-5-nano", rate: { inputPerMtok: 0.05, outputPerMtok: 0.4 } },
  { prefix: "gpt-5-mini", rate: { inputPerMtok: 0.25, outputPerMtok: 2 } },
  { prefix: "gpt-5", rate: { inputPerMtok: 1.25, outputPerMtok: 10 } },
  // GPT-4.1 系
  { prefix: "gpt-4.1-nano", rate: { inputPerMtok: 0.1, outputPerMtok: 0.4 } },
  { prefix: "gpt-4.1-mini", rate: { inputPerMtok: 0.4, outputPerMtok: 1.6 } },
  { prefix: "gpt-4.1", rate: { inputPerMtok: 2, outputPerMtok: 8 } },
  // o-series(reasoning)
  { prefix: "o3-pro", rate: { inputPerMtok: 20, outputPerMtok: 80 } },
  { prefix: "o4-mini", rate: { inputPerMtok: 1.1, outputPerMtok: 4.4 } },
  { prefix: "o3-mini", rate: { inputPerMtok: 1.1, outputPerMtok: 4.4 } },
  { prefix: "o3", rate: { inputPerMtok: 2, outputPerMtok: 8 } },
];

const TABLE: Record<string, Entry[]> = {
  anthropic: ANTHROPIC_RATES,
  google: GOOGLE_RATES,
  openai: OPENAI_RATES,
};

export function getRate(provider: string, modelId: string): ModelRate | null {
  const entries = TABLE[provider];
  if (!entries) return null;
  // Pick the longest matching prefix so `claude-opus-4-5` wins over
  // `claude-opus-4-` for `claude-opus-4-5-20251101`.
  let match: Entry | null = null;
  for (const e of entries) {
    if (modelId.startsWith(e.prefix)) {
      if (!match || e.prefix.length > match.prefix.length) match = e;
    }
  }
  return match ? match.rate : null;
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
