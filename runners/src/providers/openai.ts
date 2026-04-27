import OpenAI from "openai";
import type {
  Response,
  ResponseCreateParamsNonStreaming,
} from "openai/resources/responses/responses";
import type { CompletionRequest, CompletionResponse, Provider } from "./types.js";

export type CreateResponse = (
  params: ResponseCreateParamsNonStreaming,
) => Promise<Response>;

export interface OpenaiProviderDeps {
  /** Override responses.create for testing. */
  create?: CreateResponse;
  /** Pre-constructed SDK client. */
  client?: OpenAI;
  /** Override the API key (defaults to OPENAI_API_KEY env). */
  apiKey?: string;
}

const DEFAULT_MAX_TOKENS = 16384;

export function createOpenaiProvider(
  deps: OpenaiProviderDeps = {},
): Provider {
  const create: CreateResponse =
    deps.create ??
    ((params) => {
      const client =
        deps.client ??
        new OpenAI({
          ...(deps.apiKey ? { apiKey: deps.apiKey } : {}),
        });
      return client.responses.create(params) as Promise<Response>;
    });

  return {
    name: "openai",
    async complete(req: CompletionRequest): Promise<CompletionResponse> {
      const started = performance.now();
      if (req.messages) {
        throw new Error(
          "openai provider: ChatMessage[] history not yet supported (iterative harnesses are Anthropic-only for now)",
        );
      }
      if (req.prompt == null) {
        throw new Error("openai provider: prompt is required");
      }
      // modelOptions spread last so e.g. { reasoning: { effort: "high" } }
      // gets through to the API on reasoning models.
      const params: ResponseCreateParamsNonStreaming = {
        model: req.model,
        input: req.prompt,
        max_output_tokens: req.maxTokens ?? DEFAULT_MAX_TOKENS,
        ...(req.systemPrompt ? { instructions: req.systemPrompt } : {}),
        ...(req.modelOptions ?? {}),
      } as ResponseCreateParamsNonStreaming;
      const response = await create(params);
      const durationMs = performance.now() - started;

      if (response.status === "failed") {
        throw new Error(
          `openai provider: response failed (incomplete_details=${JSON.stringify(
            response.incomplete_details ?? null,
          )})`,
        );
      }

      // status=incomplete (e.g. hit max_output_tokens) returns empty text +
      // a stopReason so the harness can classify as no_code.
      const text = response.output_text ?? "";
      const stopReason =
        response.status === "incomplete"
          ? `incomplete:${response.incomplete_details?.reason ?? "unknown"}`
          : response.status;

      const usage = response.usage;
      const tokens =
        usage && usage.input_tokens != null && usage.output_tokens != null
          ? { input: usage.input_tokens, output: usage.output_tokens }
          : undefined;

      return {
        text,
        modelId: response.model ?? req.model,
        ...(tokens ? { tokens } : {}),
        durationMs,
        ...(stopReason ? { stopReason } : {}),
      };
    },
  };
}
