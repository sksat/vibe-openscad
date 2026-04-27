import OpenAI from "openai";
import type {
  Response,
  ResponseCreateParamsNonStreaming,
  ResponseInput,
} from "openai/resources/responses/responses";
import type {
  ChatMessage,
  CompletionRequest,
  CompletionResponse,
  Provider,
} from "./types.js";

/**
 * Translate ChatMessage[] to the OpenAI Responses API input array.
 * Multi-turn input is a list of message-shaped items with role + content
 * parts. Image inputs use a `data:` URL.
 */
function toOpenaiInput(messages: ChatMessage[]): ResponseInput {
  return messages.map((m) => {
    if (m.role === "assistant") {
      // Past assistant turns don't take typed content arrays in the
      // Responses API multi-turn input; pass them as a plain message.
      return {
        role: "assistant",
        content: m.content,
      };
    }
    if (typeof m.content === "string") {
      return { role: "user", content: m.content };
    }
    return {
      role: "user",
      content: m.content.map((p) =>
        p.type === "text"
          ? { type: "input_text" as const, text: p.text }
          : {
              type: "input_image" as const,
              detail: "auto" as const,
              image_url: `data:${p.mediaType};base64,${p.data.toString("base64")}`,
            },
      ),
    };
  }) as ResponseInput;
}

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
      const input: string | ResponseInput = req.messages
        ? toOpenaiInput(req.messages)
        : req.prompt != null
          ? req.prompt
          : (() => {
              throw new Error(
                "openai provider: either prompt or messages is required",
              );
            })();
      // modelOptions spread last so e.g. { reasoning: { effort: "high" } }
      // gets through to the API on reasoning models.
      const params: ResponseCreateParamsNonStreaming = {
        model: req.model,
        input,
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
