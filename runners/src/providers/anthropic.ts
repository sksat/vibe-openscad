import Anthropic from "@anthropic-ai/sdk";
import type { CompletionRequest, CompletionResponse, Provider } from "./types.js";

export type CreateMessage = (
  params: Anthropic.MessageCreateParamsNonStreaming,
) => Promise<Anthropic.Message>;

export interface AnthropicProviderDeps {
  /**
   * Override the Anthropic SDK's `messages.create` for testing.
   * In production, omit and a default client is constructed from env.
   */
  create?: CreateMessage;
  /** Pre-constructed SDK client (used when `create` is not provided). */
  client?: Anthropic;
}

// SCAD 出力は数百トークン程度。大きな値は古い Opus 系で
// "Streaming is required for operations that may take longer than
// 10 minutes" の SDK ガードに引っかかるため低めに。
const DEFAULT_MAX_TOKENS = 4096;

export function createAnthropicProvider(
  deps: AnthropicProviderDeps = {},
): Provider {
  const create: CreateMessage =
    deps.create ??
    (((params) =>
      (deps.client ?? new Anthropic()).messages.create(
        params,
      )) as CreateMessage);

  return {
    name: "anthropic",
    async complete(req: CompletionRequest): Promise<CompletionResponse> {
      const started = performance.now();
      // modelOptions are spread last so caller-provided values (e.g.
      // `thinking: {type: "adaptive"}`) override defaults.
      const params: Anthropic.MessageCreateParamsNonStreaming = {
        model: req.model,
        max_tokens: req.maxTokens ?? DEFAULT_MAX_TOKENS,
        messages: [{ role: "user", content: req.prompt }],
        ...(req.systemPrompt ? { system: req.systemPrompt } : {}),
        ...(req.modelOptions ?? {}),
      } as Anthropic.MessageCreateParamsNonStreaming;
      const message = await create(params);
      const durationMs = performance.now() - started;

      const text = message.content
        .filter((b): b is Anthropic.TextBlock => b.type === "text")
        .map((b) => b.text)
        .join("");

      if (!text) {
        throw new Error(
          `anthropic provider: no text blocks in response (stop_reason=${message.stop_reason})`,
        );
      }

      return {
        text,
        modelId: message.model,
        tokens: {
          input: message.usage.input_tokens,
          output: message.usage.output_tokens,
        },
        durationMs,
        ...(message.stop_reason ? { stopReason: message.stop_reason } : {}),
      };
    },
  };
}
