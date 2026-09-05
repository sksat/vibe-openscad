import {
  GoogleGenAI,
  type Content,
  type GenerateContentParameters,
  type GenerateContentResponse,
  type Part,
} from "@google/genai";
import type {
  ChatMessage,
  CompletionRequest,
  CompletionResponse,
  Provider,
} from "./types.js";

/** Translate our generic ChatMessage[] to Gemini Content[]. */
function toGeminiContents(messages: ChatMessage[]): Content[] {
  return messages.map((m) => {
    // Gemini uses "model" for assistant turns. assistant content is always
    // a plain string (declared in our types), so a single text part suffices.
    if (m.role === "assistant") {
      return { role: "model", parts: [{ text: m.content }] };
    }
    if (typeof m.content === "string") {
      return { role: "user", parts: [{ text: m.content }] };
    }
    const parts: Part[] = m.content.map((p) =>
      p.type === "text"
        ? { text: p.text }
        : {
            inlineData: {
              mimeType: p.mediaType,
              data: p.data.toString("base64"),
            },
          },
    );
    return { role: "user", parts };
  });
}

export type GenerateContent = (
  params: GenerateContentParameters,
) => Promise<GenerateContentResponse>;

export interface GoogleProviderDeps {
  /** Override generateContent for testing. */
  generate?: GenerateContent;
  /** Pre-constructed SDK client. */
  client?: GoogleGenAI;
  /** Override the API key (defaults to GEMINI_API_KEY / GOOGLE_API_KEY env). */
  apiKey?: string;
}

// Gemini は thinking トークンが maxOutputTokens に含まれるため、
// 出力 + 思考の合計を見込んで広めに取る。Anthropic と違い SDK 側の
// "10 分タイムアウト" 制約は無い。
const DEFAULT_MAX_TOKENS = 16384;

export function createGoogleProvider(
  deps: GoogleProviderDeps = {},
): Provider {
  const generate: GenerateContent =
    deps.generate ??
    (async (params) => {
      const apiKey =
        deps.apiKey ??
        process.env["GEMINI_API_KEY"] ??
        process.env["GOOGLE_API_KEY"];
      if (!apiKey) {
        throw new Error(
          "google provider: GEMINI_API_KEY or GOOGLE_API_KEY is not set",
        );
      }
      const client = deps.client ?? new GoogleGenAI({ apiKey });
      return client.models.generateContent(params);
    });

  return {
    name: "google",
    async complete(req: CompletionRequest): Promise<CompletionResponse> {
      const started = performance.now();
      const contents: Content[] | string = req.messages
        ? toGeminiContents(req.messages)
        : req.prompt != null
          ? req.prompt
          : (() => {
              throw new Error(
                "google provider: either prompt or messages is required",
              );
            })();
      // modelOptions: top-level fields spread directly; `config` sub-object
      // is shallow-merged with our defaults so callers can override pieces
      // like { config: { thinkingConfig: { thinkingBudget: 0 } } } without
      // losing maxOutputTokens / systemInstruction.
      const opts = req.modelOptions ?? {};
      const optsConfig =
        typeof opts["config"] === "object" && opts["config"] !== null
          ? (opts["config"] as Record<string, unknown>)
          : undefined;
      const { config: _, ...optsTopLevel } = opts as { config?: unknown };
      const params: GenerateContentParameters = {
        model: req.model,
        contents,
        config: {
          maxOutputTokens: req.maxTokens ?? DEFAULT_MAX_TOKENS,
          ...(req.systemPrompt
            ? { systemInstruction: req.systemPrompt }
            : {}),
          ...(optsConfig ?? {}),
        },
        ...optsTopLevel,
      } as GenerateContentParameters;
      const response = await generate(params);
      const durationMs = performance.now() - started;

      const stopReason = response.candidates?.[0]?.finishReason;
      // Empty text is legitimate (e.g. finishReason=MAX_TOKENS when Gemini's
      // thinking tokens consumed the budget). Surface it as empty + stopReason
      // so the harness can classify as no_code rather than api_error.
      const text = response.text ?? "";
      if (!response.candidates || response.candidates.length === 0) {
        throw new Error(
          `google provider: no candidates in response (stopReason=${stopReason ?? "unknown"})`,
        );
      }

      const usage = response.usageMetadata;
      // Gemini は thinking を thoughtsTokenCount として candidatesTokenCount と
      // 分けて返すが、課金は出力扱いで maxOutputTokens もこの合計に効く。
      // Anthropic の output_tokens も OpenAI の output_tokens も reasoning を
      // 含んでいるので、output に合算して揃える(thinking 単体も残す)。
      const thinking = usage?.thoughtsTokenCount;
      const tokens =
        usage?.promptTokenCount != null && usage?.candidatesTokenCount != null
          ? {
              input: usage.promptTokenCount,
              output: usage.candidatesTokenCount + (thinking ?? 0),
              ...(thinking != null ? { thinking } : {}),
            }
          : undefined;
      return {
        text,
        modelId: response.modelVersion ?? req.model,
        ...(tokens ? { tokens } : {}),
        durationMs,
        ...(stopReason ? { stopReason } : {}),
      };
    },
  };
}
