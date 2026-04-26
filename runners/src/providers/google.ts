import {
  GoogleGenAI,
  type GenerateContentParameters,
  type GenerateContentResponse,
} from "@google/genai";
import type { CompletionRequest, CompletionResponse, Provider } from "./types.js";

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
        contents: req.prompt,
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
      const tokens =
        usage?.promptTokenCount != null && usage?.candidatesTokenCount != null
          ? {
              input: usage.promptTokenCount,
              output: usage.candidatesTokenCount,
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
