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

// SCAD 出力は数百トークン程度なので、明示しないモデルはこの値で足りる。
// thinking が既定 on のモデル(Fable 5 / Opus 5 / Sonnet 5 等)は思考トークンも
// この上限を消費するので、bench-config 側の modelOptions で個別に引き上げる。
const DEFAULT_MAX_TOKENS = 4096;

export function createAnthropicProvider(
  deps: AnthropicProviderDeps = {},
): Provider {
  // 本番経路はストリーミング。非ストリーミングの messages.create は
  // max_tokens > 16000 を SDK が "Streaming is required for operations that
  // may take longer than 10 minutes" で送信前に弾くため、thinking が既定 on の
  // モデルに十分な上限を与えられない(16k では思考の途中で切れて SCAD が
  // 出ない)。OpenAI provider が同じ理由でストリーミングを使っているのと揃える。
  // 結果と所要時間は非ストリーミングと同じで、テストは deps.create を注入して
  // この経路を迂回する。
  const create: CreateMessage =
    deps.create ??
    (async (params) => {
      const client = deps.client ?? new Anthropic();
      return client.messages.stream(params).finalMessage();
    });

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

      // max_tokens で text block ゼロのまま停止するのは「SCAD を返さなかった」
      // というモデル挙動の観測(→ harness 側で no_code になる)。throw すると
      // api_error 扱いで results に残らず永久リトライになるので、空テキストの
      // まま返す。それ以外の text 欠落は想定外なので従来どおり throw。
      if (!text && message.stop_reason !== "max_tokens") {
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
