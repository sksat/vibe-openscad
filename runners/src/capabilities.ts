/**
 * Per-model capability flags. Used by harnesses to bail out early when a
 * configured iteration strategy requires a capability the target model
 * doesn't have (e.g. render-png-feedback on a vision-less model).
 *
 * Provider-level guards are too coarse — within one provider, different
 * models have different capabilities (e.g. OpenAI o1 has no vision but
 * o3 / o4-mini / gpt-4.1 / gpt-5 family do; Gemini 2.5 / 3 are uniformly
 * multimodal). Match by base name (date suffix stripped).
 */

/** Strip a `-YYYYMMDD` or `-YYYY-MM-DD` snapshot suffix. */
function baseName(model: string): string {
  return model.replace(/-\d{4}-\d{2}-\d{2}$/, "").replace(/-\d{8}$/, "");
}

const VISION_CAPABLE: RegExp[] = [
  // Anthropic: Claude 3+ multimodal across the board.
  /^claude-(opus|sonnet|haiku)-\d/,
  // Google Gemini: 1.5 / 2.5 / 3.x families all accept inline images.
  /^gemini-/,
  // Google Gemma 3+ (vlm) self-hosted: `google/gemma-3-27b`, `google/gemma-4-e2b` 等。
  // LM Studio 上で `type: "vlm"` として配布されている系統。
  /^google\/gemma-[34]-/,
  // OpenAI multimodal chat models.
  /^gpt-4o/,
  /^gpt-4\.1/,
  /^gpt-5(\.\d+)?(-mini|-nano|-pro)?$/,
  // GPT-5 codex variants (5-codex, 5.1-codex / -max / -mini, 5.2-codex,
  // 5.3-codex) accept image input.
  /^gpt-5(\.\d+)?-codex(-max|-mini)?$/,
  // OpenAI o-series reasoning: o1 lacks vision; o3 / o4-mini / o3-pro support
  // it. Be conservative and enumerate the ones we know.
  /^o3$/,
  /^o3-pro$/,
  /^o4-mini$/,
];

export function modelSupportsVision(model: string): boolean {
  const base = baseName(model);
  return VISION_CAPABLE.some((rx) => rx.test(base));
}
