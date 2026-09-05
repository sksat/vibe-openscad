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

/**
 * ストリーミング 1 回あたりの上限(30 分)。effort max + max_tokens 64000 の
 * run でも数分で収まる一方、SSE が停止したときは確実に失敗させる。
 */
const STREAM_TIMEOUT_MS = 30 * 60 * 1000;

/**
 * 非ストリーミングで送れる max_tokens の上限。SDK は送信前に
 * `3600 * max_tokens / 128000` 秒を見積もり、10 分を超えると
 * "Streaming is required for operations that may take longer than 10 minutes"
 * を投げる。境界は 600 * 128000 / 3600 = 21333.33 なので 21333 までが可
 * (実測で 21333 は通り 21334 で拒否)。モデル非依存の固定式。
 *
 * **転送方式を max_tokens だけで決めるのが重要**: max_tokens は modelOptions
 * 経由で fingerprint に乗るので、こうしておくと「同じ signature なら必ず同じ
 * 転送方式」が成り立つ。無条件にストリーミングへ切り替えると、既存エントリは
 * signature が変わらないまま転送方式だけが変わり、差が出たときに検出できない。
 */
const MAX_NONSTREAMING_TOKENS = 21333;

// SCAD 出力は数百トークン程度なので、明示しないモデルはこの値で足りる。
// thinking が既定 on のモデル(Fable 5 / Opus 5 / Sonnet 5 等)は thinking token
// もこの上限を消費するので、bench-config 側の modelOptions で引き上げる。
const DEFAULT_MAX_TOKENS = 4096;

export function createAnthropicProvider(
  deps: AnthropicProviderDeps = {},
): Provider {
  // max_tokens が SDK の非ストリーミング上限を超えるときだけストリーミングに
  // 切り替える。thinking が既定 on のモデル(Fable 5 / Opus 5 / Sonnet 5 等)は
  // thinking token も max_tokens を消費するので十分な上限が要るが、非ストリーミング
  // では 21333 までしか送れない。
  //
  // 上限以下の既存エントリは従来どおり非ストリーミングのままにする。転送方式が
  // max_tokens の関数になるので、同じ signature の run は必ず同じ経路を通る。
  // テストは deps.create を注入してこの分岐ごと迂回する。
  const create: CreateMessage =
    deps.create ??
    (async (params) => {
      const client = deps.client ?? new Anthropic();
      if ((params.max_tokens ?? 0) <= MAX_NONSTREAMING_TOKENS) {
        return client.messages.create(params);
      }
      // SSE が途中で無音になった場合、finalMessage() には打ち切る手段が無く
      // 待ち続ける。bench-config の defaults.timeoutSec は provider 呼び出しに
      // 配線されていないので、ここで明示的に上限を持たせないと 1 件の停止で
      // ベンチ全体が終わらなくなる。
      return client.messages
        .stream(params, { timeout: STREAM_TIMEOUT_MS })
        .finalMessage();
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
