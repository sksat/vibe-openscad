/**
 * ローカル LLM(Ollama / LM Studio / llama.cpp / vLLM など)用 provider。
 * 各ランタイムが共通で持つ **OpenAI 互換エンドポイント** (`/v1/chat/completions`
 * `/v1/models`) を叩く実装。Ollama 本体は `/api/chat` の native API も持つが、
 * LM Studio は標準で OpenAI 互換のみ提供のため、最大公約数として /v1 を使う。
 *
 * provider 名は歴史的に `ollama` のまま(env var `OLLAMA_HOST` も含めて)。
 * 実体は「ローカル OpenAI 互換 host」と読み替えてもらえる。
 *
 * ホスト解決:
 * - `OLLAMA_HOST` 環境変数を最優先(例: `http://asuha:1234`)
 * - 無ければ `http://127.0.0.1:11434`(Ollama 既定)
 *
 * 画像入力(vision):
 * - OpenAI 互換の `{ type: "image_url", image_url: { url: "data:...;base64,..." } }`
 *   形式で渡す。vision 対応モデル(llava, qwen2-vl 等)が認識する
 *
 * 注意: ローカル LLM は VRAM ボトルネックなので bench-config の
 * `defaults.concurrency.perProvider.ollama` を 1 に絞ることを推奨。
 */
import OpenAI from "openai";
import type {
  ChatCompletionCreateParamsNonStreaming,
  ChatCompletionMessageParam,
} from "openai/resources/chat/completions";
import type {
  ChatMessage,
  CompletionRequest,
  CompletionResponse,
  Provider,
} from "./types.js";

function ollamaHost(): string {
  return process.env["OLLAMA_HOST"] ?? "http://127.0.0.1:11434";
}

/**
 * provider 共通形式 → OpenAI ChatCompletion 形式に変換。
 * - text + image を持つ user メッセージは content array にする(`{type:"text"}`
 *   と `{type:"image_url", image_url:{url:"data:.."}}` を混ぜる)
 * - assistant は plain text のみ想定(現状の harness と一致)
 */
function toOpenAIMessages(
  messages: ChatMessage[],
): ChatCompletionMessageParam[] {
  return messages.map<ChatCompletionMessageParam>((m) => {
    if (m.role === "assistant") {
      return { role: "assistant", content: m.content };
    }
    if (typeof m.content === "string") {
      return { role: "user", content: m.content };
    }
    const parts = m.content.map((p) => {
      if (p.type === "text") return { type: "text" as const, text: p.text };
      return {
        type: "image_url" as const,
        image_url: {
          url: `data:${p.mediaType};base64,${p.data.toString("base64")}`,
        },
      };
    });
    return { role: "user", content: parts };
  });
}

export interface OllamaProviderDeps {
  /** OpenAI SDK client(テスト時は mock を inject)。 */
  client?: OpenAI;
  /** ホスト override(env より優先)。 */
  host?: string;
  /** API key。LM Studio は無視するが Ollama は空でも OK。`"ollama"` 等のダミーで可。 */
  apiKey?: string;
}

export function createOllamaProvider(
  deps: OllamaProviderDeps = {},
): Provider {
  const host = (deps.host ?? ollamaHost()).replace(/\/$/, "");
  const client =
    deps.client ??
    new OpenAI({
      baseURL: `${host}/v1`,
      // SDK は apiKey 必須。LM Studio / Ollama 双方ダミーで通る。
      apiKey: deps.apiKey ?? "ollama",
    });
  return {
    name: "ollama",
    async complete(req: CompletionRequest): Promise<CompletionResponse> {
      const start = performance.now();
      const messages: ChatCompletionMessageParam[] = [];
      if (req.systemPrompt) {
        messages.push({ role: "system", content: req.systemPrompt });
      }
      if (req.prompt !== undefined) {
        messages.push({ role: "user", content: req.prompt });
      } else if (req.messages) {
        messages.push(...toOpenAIMessages(req.messages));
      } else {
        throw new Error("ollama: prompt or messages must be provided");
      }
      const params: ChatCompletionCreateParamsNonStreaming = {
        model: req.model,
        messages,
        // ローカル LLM 側 max_tokens は実装によって名前が違う(num_predict
        // 等)。modelOptions に `max_tokens` を入れて override する想定。
        ...(req.modelOptions ?? {}),
      };
      const res = await client.chat.completions.create(params);
      const choice = res.choices[0];
      const out: CompletionResponse = {
        text: choice?.message?.content ?? "",
        modelId: res.model ?? req.model,
        durationMs: performance.now() - start,
        ...(choice?.finish_reason ? { stopReason: choice.finish_reason } : {}),
      };
      if (res.usage) {
        out.tokens = {
          input: res.usage.prompt_tokens,
          output: res.usage.completion_tokens,
        };
      }
      return out;
    },
  };
}
