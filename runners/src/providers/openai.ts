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
 * Concatenate `output_text` parts out of the structured `output` array of
 * a Responses API result. Needed because the SDK's convenience accessor
 * `Response.output_text` is undefined on streamed responses, while the
 * `output[]` structure is correctly populated either way.
 */
function extractOutputText(response: Response): string {
  const parts: string[] = [];
  const output = (response as unknown as { output?: unknown[] }).output ?? [];
  for (const item of output) {
    if (
      typeof item === "object" &&
      item !== null &&
      (item as { type?: string }).type === "message"
    ) {
      const content = (item as { content?: unknown[] }).content ?? [];
      for (const c of content) {
        if (
          typeof c === "object" &&
          c !== null &&
          (c as { type?: string }).type === "output_text" &&
          typeof (c as { text?: unknown }).text === "string"
        ) {
          parts.push((c as { text: string }).text);
        }
      }
    }
  }
  return parts.join("");
}

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

/**
 * ストリーミング 1 回あたりの上限(30 分)。effort max の長い run でも数分で
 * 収まる一方、SSE が停止したときは確実に失敗させる。Anthropic provider と
 * 同じ値。
 */
const STREAM_TIMEOUT_MS = 30 * 60 * 1000;

// reasoning effort=high の o-series / gpt-5 family はサンプリングだけでなく
// 内部の reasoning tokens も output 上限に算入されるため、16k だと mug
// 等の中等課題で incomplete:max_output_tokens に当たる。32k に上げて
// 余裕を持たせる(billing は実消費分のみ)。
const DEFAULT_MAX_TOKENS = 32768;

export function createOpenaiProvider(
  deps: OpenaiProviderDeps = {},
): Provider {
  // Production default uses the streaming API + .finalResponse() instead of
  // non-streaming responses.create. Identical wall-clock and final result,
  // but the long-lived SSE connection avoids the SDK's 10-minute HTTP
  // timeout that bites reasoning models with high effort + 32k output cap.
  // Tests typically inject deps.create directly to bypass this path.
  const create: CreateResponse =
    deps.create ??
    (async (params) => {
      const client =
        deps.client ??
        new OpenAI({
          ...(deps.apiKey ? { apiKey: deps.apiKey } : {}),
        });
      const stream = await (
        client.responses as unknown as {
          stream: (
            p: ResponseCreateParamsNonStreaming,
            opts: { timeout: number },
          ) => Promise<{
            [Symbol.asyncIterator](): AsyncIterator<unknown>;
            finalResponse(): Promise<Response>;
          }>;
        }
      ).stream(params, { timeout: STREAM_TIMEOUT_MS });
      // Drain events to keep the connection alive until completion. Hook
      // here later if we want a progress callback (token counts etc).
      for await (const _evt of stream) {
        void _evt;
      }
      return stream.finalResponse();
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
      // Note: `output_text` accessor is only populated on the non-streaming
      // response path. With streaming finalResponse() it comes back undefined
      // even when text is present, so we always reconstruct from the
      // structured `output[].content[]` and fall back to output_text.
      const text =
        extractOutputText(response) || (response.output_text ?? "");
      const stopReason =
        response.status === "incomplete"
          ? `incomplete:${response.incomplete_details?.reason ?? "unknown"}`
          : response.status;

      const usage = response.usage;
      // output_tokens は reasoning を含んだ値。内訳は
      // output_tokens_details.reasoning_tokens として別に返る。
      const reasoning = usage?.output_tokens_details?.reasoning_tokens;
      const tokens =
        usage && usage.input_tokens != null && usage.output_tokens != null
          ? {
              input: usage.input_tokens,
              output: usage.output_tokens,
              ...(reasoning != null ? { thinking: reasoning } : {}),
            }
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
