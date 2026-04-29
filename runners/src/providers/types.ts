export interface CompletionRequest {
  /** Single-shot prompt. Mutually exclusive with `messages`. */
  prompt?: string;
  /**
   * Multi-turn message history (used by iterative harnesses to feed
   * render images back to the model). Mutually exclusive with `prompt`.
   */
  messages?: ChatMessage[];
  model: string;
  maxTokens?: number;
  systemPrompt?: string;
  /**
   * Provider-specific extra parameters merged into the SDK call.
   * Shape is up to the caller — e.g. for OpenAI:
   *   { reasoning: { effort: "high" } }
   * for Anthropic:
   *   { thinking: { type: "adaptive" } }
   * for Google (merged into config):
   *   { config: { thinkingConfig: { thinkingBudget: 0 } } }
   */
  modelOptions?: Record<string, unknown>;
}

export type ChatMessage =
  | { role: "user"; content: string | ChatContentPart[] }
  | { role: "assistant"; content: string };

export type ChatContentPart =
  | { type: "text"; text: string }
  | { type: "image"; mediaType: "image/png" | "image/jpeg"; data: Buffer };

export interface CompletionResponse {
  /** Concatenated text content from all text blocks. */
  text: string;
  /** Model ID echoed back by the API (may differ from requested for aliases). */
  modelId: string;
  /** Token usage. */
  tokens?: { input: number; output: number };
  /** Wall-clock duration in ms. */
  durationMs: number;
  /** Stop reason from the API, if available. */
  stopReason?: string;
}

/**
 * Self-hosted ランタイム(LM Studio / Ollama)から拾える、モデル個体を
 * 識別する追加メタデータ。クラウド provider(openai / anthropic /
 * google)は API でこの粒度の情報を出さないので undefined を返す。
 *
 * 記録目的: 同じ model id でも(モデル開発者, 重みの publisher, 量子化)
 * が違えば挙動が変わる。クラウドの単一文字列 `provider` に対して
 * self-hosted は実質「(モデル開発者, publisher)」の組で識別される
 * (例: openai 製 gpt-oss-20b の lmstudio-community 版 vs unsloth 版)。
 * これらを meta.json に同梱して後から再現性を追えるようにする。
 */
export interface ModelMetadata {
  /** 重みの配布元(LM Studio: `publisher`)。例: openai, qwen, unsloth */
  publisher?: string;
  /** モデル形態(LM Studio: `type`)。`llm` / `vlm` / `embeddings` 等 */
  type?: string;
  /** アーキ family(LM Studio: `arch`、Ollama: `details.family`)。 */
  arch?: string;
  /** 量子化(LM Studio: `quantization`、Ollama: `details.quantization_level`)。 */
  quantization?: string;
  /** max context tokens(LM Studio のみ)。 */
  maxContextLength?: number;
  /** capabilities tag(LM Studio のみ)。例: ["tool_use"]、["vision"] */
  capabilities?: string[];
  /** parameter size like "27B"(Ollama のみ)。 */
  parameterSize?: string;
  /** weight ファイル size in bytes(Ollama のみ)。 */
  size?: number;
  /** デバッグ用に raw response も残す。 */
  raw?: Record<string, unknown>;
}

export interface Provider {
  /** Stable identifier, e.g. "anthropic". */
  readonly name: string;
  complete(req: CompletionRequest): Promise<CompletionResponse>;
  /**
   * オプション: モデル個体メタデータを取得する。run のたびに呼ばれて
   * meta.json に記録される。実装が無いか null/undefined を返した
   * provider は metadata 無しで run する。
   */
  getModelMetadata?(model: string): Promise<ModelMetadata | null>;
}
