/**
 * セルフホスト OpenAI 互換 endpoint 用 provider。
 * Ollama / LM Studio / llama.cpp / vLLM など、`/v1/chat/completions` と
 * `/v1/models` を提供する任意のランタイムを「OpenAI と同じ pipeline」
 * で扱う。クラウド OpenAI(`provider: openai`)と区別するため
 * `provider: openai-self-hosted` と命名。
 *
 * Ollama 本体は `/api/chat` の native API も持つが、LM Studio 等は
 * 標準で OpenAI 互換のみ提供のため、最大公約数として /v1 を使う。
 *
 * Base URL 解決:
 * - `OPENAI_SELF_HOSTED_BASE_URL` 環境変数を最優先
 *   (例: `http://asuha:1234/v1`、末尾 `/v1` 込みで設定)
 * - フォールバック: 旧 `OLLAMA_HOST` 環境変数があればそれに `/v1` を付ける
 * - 無ければ `http://127.0.0.1:11434/v1`(Ollama 既定の /v1 互換)
 *
 * 画像入力(vision):
 * - OpenAI 互換の `{ type: "image_url", image_url: { url: "data:...;base64,..." } }`
 *   形式で渡す。vision 対応モデル(llava, qwen2-vl 等)が認識する
 *
 * 注意: ローカル LLM は VRAM ボトルネックなので bench-config の
 * `defaults.concurrency.perProvider.openai-self-hosted` を 1 に絞ることを
 * 推奨。
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
  ModelMetadata,
  Provider,
} from "./types.js";

/**
 * `OPENAI_SELF_HOSTED_BASE_URL` をそのまま、無ければ旧来の `OLLAMA_HOST`
 * を /v1 に補正、両方無ければ ollama 既定 + /v1 を返す。末尾の `/` は
 * caller 側で正規化。
 */
function defaultBaseUrl(): string {
  const explicit = process.env["OPENAI_SELF_HOSTED_BASE_URL"];
  if (explicit) return explicit;
  const legacy = process.env["OLLAMA_HOST"];
  if (legacy) {
    return legacy.replace(/\/$/, "") + "/v1";
  }
  return "http://127.0.0.1:11434/v1";
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

export interface OpenAISelfHostedProviderDeps {
  /** OpenAI SDK client(テスト時は mock を inject)。 */
  client?: OpenAI;
  /** Base URL override(env より優先)。`/v1` まで含めて指定。 */
  baseURL?: string;
  /** API key。LM Studio / Ollama 双方ダミーで通る。 */
  apiKey?: string;
}

export function createOpenAISelfHostedProvider(
  deps: OpenAISelfHostedProviderDeps = {},
): Provider {
  const baseURL = (deps.baseURL ?? defaultBaseUrl()).replace(/\/$/, "");
  const client =
    deps.client ??
    new OpenAI({
      baseURL,
      // SDK は apiKey 必須。LM Studio / Ollama 双方ダミーで通る。
      apiKey: deps.apiKey ?? "self-hosted",
    });
  return {
    name: "openai-self-hosted",
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
        throw new Error(
          "openai-self-hosted: prompt or messages must be provided",
        );
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
    /**
     * 量子化や publisher などの情報を取得して run.meta.json に同梱する
     * ため、host の `/api/v0/models` (LM Studio native) → `/api/tags`
     * (Ollama) の順で問い合わせて、対象モデル id にマッチするエントリを
     * `ModelMetadata` 形に正規化して返す。`/v1/models` だけしか応答しない
     * 環境では `null`(取れる情報が id しか無いので意味が無い)。
     *
     * 結果はプロセス内でメモ化する(同 model を 1 run 中に何度叩いても
     * 1 回だけ HTTP を打つ)。
     */
    async getModelMetadata(model: string): Promise<ModelMetadata | null> {
      const cached = metadataCache.get(`${baseURL}::${model}`);
      if (cached !== undefined) return cached;
      const md = await fetchModelMetadata(baseURL, model);
      metadataCache.set(`${baseURL}::${model}`, md);
      return md;
    },
  };
}

/** プロセス内 LRU 代わりの単純 Map。base URL × model 単位でキャッシュ。 */
const metadataCache = new Map<string, ModelMetadata | null>();

interface LMStudioModelEntry {
  id: string;
  type?: string;
  publisher?: string;
  arch?: string;
  quantization?: string;
  state?: string;
  max_context_length?: number;
  capabilities?: string[];
}
interface OllamaTag {
  name: string;
  model?: string;
  size?: number;
  details?: {
    parameter_size?: string;
    quantization_level?: string;
    family?: string;
  };
}

async function fetchModelMetadata(
  baseURL: string,
  model: string,
): Promise<ModelMetadata | null> {
  const hostRoot = baseURL.replace(/\/v1$/, "");
  // Try LM Studio native first.
  try {
    const res = await fetch(`${hostRoot}/api/v0/models`);
    if (res.ok) {
      const json = (await res.json()) as { data?: LMStudioModelEntry[] };
      const hit = (json.data ?? []).find((m) => m.id === model);
      if (hit) {
        const md: ModelMetadata = { raw: hit as unknown as Record<string, unknown> };
        if (hit.publisher) md.publisher = hit.publisher;
        if (hit.type) md.type = hit.type;
        if (hit.arch) md.arch = hit.arch;
        if (hit.quantization) md.quantization = hit.quantization;
        if (typeof hit.max_context_length === "number")
          md.maxContextLength = hit.max_context_length;
        if (hit.capabilities && hit.capabilities.length > 0)
          md.capabilities = hit.capabilities;
        return md;
      }
    }
  } catch {
    // ignore, fall through
  }
  // Fallback: Ollama native /api/tags
  try {
    const res = await fetch(`${hostRoot}/api/tags`);
    if (res.ok) {
      const json = (await res.json()) as { models?: OllamaTag[] };
      const hit = (json.models ?? []).find(
        (m) => m.name === model || m.model === model,
      );
      if (hit) {
        const md: ModelMetadata = { raw: hit as unknown as Record<string, unknown> };
        if (hit.details?.family) md.arch = hit.details.family;
        if (hit.details?.quantization_level)
          md.quantization = hit.details.quantization_level;
        if (hit.details?.parameter_size)
          md.parameterSize = hit.details.parameter_size;
        if (typeof hit.size === "number") md.size = hit.size;
        return md;
      }
    }
  } catch {
    // ignore
  }
  return null;
}
