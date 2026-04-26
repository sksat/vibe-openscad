export interface CompletionRequest {
  prompt: string;
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

export interface Provider {
  /** Stable identifier, e.g. "anthropic". */
  readonly name: string;
  complete(req: CompletionRequest): Promise<CompletionResponse>;
}
