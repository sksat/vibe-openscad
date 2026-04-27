import Anthropic from "@anthropic-ai/sdk";
import type {
  ChatMessage,
  CompletionRequest,
  CompletionResponse,
  Provider,
} from "./types.js";

/** Translate our generic ChatMessage[] to Anthropic SDK message params. */
function toAnthropicMessages(
  messages: ChatMessage[],
): Anthropic.MessageParam[] {
  return messages.map((m) => {
    if (m.role === "assistant") {
      return { role: "assistant", content: m.content };
    }
    if (typeof m.content === "string") {
      return { role: "user", content: m.content };
    }
    return {
      role: "user",
      content: m.content.map((p) => {
        if (p.type === "text") return { type: "text", text: p.text };
        return {
          type: "image",
          source: {
            type: "base64",
            media_type: p.mediaType,
            data: p.data.toString("base64"),
          },
        };
      }),
    };
  });
}

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
      const messages: Anthropic.MessageParam[] = req.messages
        ? toAnthropicMessages(req.messages)
        : req.prompt != null
          ? [{ role: "user", content: req.prompt }]
          : (() => {
              throw new Error(
                "anthropic provider: either prompt or messages is required",
              );
            })();
      const params: Anthropic.MessageCreateParamsNonStreaming = {
        model: req.model,
        max_tokens: req.maxTokens ?? DEFAULT_MAX_TOKENS,
        messages,
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
