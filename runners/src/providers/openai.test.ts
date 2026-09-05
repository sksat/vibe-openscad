import type OpenAI from "openai";
import { describe, expect, it, vi } from "vitest";
import { createOpenaiProvider } from "./openai.js";

interface FakeResponse {
  output_text?: string;
  model?: string;
  usage?: { input_tokens?: number; output_tokens?: number };
  status?: "completed" | "incomplete" | "failed";
  incomplete_details?: { reason?: string } | null;
}

function fakeResp(overrides: FakeResponse = {}): FakeResponse {
  return {
    output_text: "hello",
    model: "gpt-5",
    usage: { input_tokens: 10, output_tokens: 5 },
    status: "completed",
    incomplete_details: null,
    ...overrides,
  };
}

describe("createOpenaiProvider", () => {
  it("bounds the stream with a finite timeout", async () => {
    // SSE が途中で無音になるとドレインループが終わらず finalResponse() も
    // 返らない。bench-config の timeoutSec は provider 呼び出しに配線されて
    // いないので、ここで上限を持たせないと 1 件の停止でベンチ全体が
    // 終わらなくなる(Anthropic 側は #11 で同じ対応をしている)。
    const finalResponse = vi.fn().mockResolvedValue(fakeResp());
    const stream = vi.fn().mockResolvedValue({
      [Symbol.asyncIterator]: () => ({
        next: async () => ({ done: true, value: undefined }),
      }),
      finalResponse,
    });
    const provider = createOpenaiProvider({
      client: { responses: { stream } } as unknown as OpenAI,
    });

    await provider.complete({ prompt: "p", model: "gpt-5.6-sol" });

    const opts = stream.mock.calls[0]?.[1];
    expect(typeof opts?.timeout).toBe("number");
    expect(Number.isFinite(opts.timeout)).toBe(true);
    expect(opts.timeout).toBeGreaterThan(0);
  });

  it("name is 'openai'", () => {
    const provider = createOpenaiProvider({ create: vi.fn() });
    expect(provider.name).toBe("openai");
  });

  it("calls responses.create with model + input + max_output_tokens", async () => {
    const create = vi.fn().mockResolvedValue(fakeResp());
    const provider = createOpenaiProvider({ create });

    await provider.complete({ prompt: "make a cube", model: "gpt-5" });

    expect(create).toHaveBeenCalledTimes(1);
    const call = create.mock.calls[0]?.[0];
    expect(call.model).toBe("gpt-5");
    expect(call.input).toBe("make a cube");
    expect(typeof call.max_output_tokens).toBe("number");
  });

  it("merges modelOptions like { reasoning: { effort: 'high' } } into the SDK call", async () => {
    const create = vi.fn().mockResolvedValue(fakeResp());
    const provider = createOpenaiProvider({ create });
    await provider.complete({
      prompt: "p",
      model: "o3",
      modelOptions: { reasoning: { effort: "high" } },
    });
    const call = create.mock.calls[0]?.[0];
    expect(call.reasoning).toEqual({ effort: "high" });
  });

  it("forwards systemPrompt as instructions and maxTokens as max_output_tokens", async () => {
    const create = vi.fn().mockResolvedValue(fakeResp());
    const provider = createOpenaiProvider({ create });

    await provider.complete({
      prompt: "p",
      model: "gpt-5-mini",
      systemPrompt: "Be concise.",
      maxTokens: 2048,
    });

    const call = create.mock.calls[0]?.[0];
    expect(call.instructions).toBe("Be concise.");
    expect(call.max_output_tokens).toBe(2048);
  });

  it("returns text + tokens + model + stopReason", async () => {
    const create = vi.fn().mockResolvedValue(
      fakeResp({
        output_text: "result-text",
        model: "gpt-5-2025-09-15",
        usage: { input_tokens: 50, output_tokens: 25 },
      }),
    );
    const provider = createOpenaiProvider({ create });

    const r = await provider.complete({ prompt: "p", model: "gpt-5" });
    expect(r.text).toBe("result-text");
    expect(r.tokens).toEqual({ input: 50, output: 25 });
    expect(r.modelId).toBe("gpt-5-2025-09-15");
    expect(r.stopReason).toBe("completed");
    expect(r.durationMs).toBeGreaterThanOrEqual(0);
  });

  it("returns empty text + incomplete reason instead of throwing on incomplete", async () => {
    const create = vi.fn().mockResolvedValue(
      fakeResp({
        output_text: "",
        status: "incomplete",
        incomplete_details: { reason: "max_output_tokens" },
      }),
    );
    const provider = createOpenaiProvider({ create });
    const r = await provider.complete({ prompt: "p", model: "gpt-5" });
    expect(r.text).toBe("");
    expect(r.stopReason).toBe("incomplete:max_output_tokens");
  });

  it("throws on hard failure (status=failed)", async () => {
    const create = vi.fn().mockResolvedValue(
      fakeResp({ status: "failed", output_text: "" }),
    );
    const provider = createOpenaiProvider({ create });
    await expect(
      provider.complete({ prompt: "p", model: "gpt-5" }),
    ).rejects.toThrow();
  });

  it("uses responses.stream + finalResponse when no explicit create is injected", async () => {
    // Production path: provider should call streaming API to avoid SDK
    // 10-min HTTP timeouts on long reasoning calls. With deps.client given,
    // we can verify which method (create vs stream) gets invoked.
    const finalResp = fakeResp({ output_text: "streamed-result" });
    const fakeStream = {
      [Symbol.asyncIterator]() {
        return { next: async () => ({ done: true, value: undefined }) };
      },
      finalResponse: vi.fn().mockResolvedValue(finalResp),
    };
    const responsesStream = vi.fn().mockResolvedValue(fakeStream);
    const responsesCreate = vi.fn();
    const fakeClient = {
      responses: { create: responsesCreate, stream: responsesStream },
    } as unknown as NonNullable<
      NonNullable<Parameters<typeof createOpenaiProvider>[0]>["client"]
    >;
    const provider = createOpenaiProvider({ client: fakeClient });

    const r = await provider.complete({ prompt: "hi", model: "gpt-5" });
    expect(responsesStream).toHaveBeenCalledTimes(1);
    expect(responsesCreate).not.toHaveBeenCalled();
    expect(r.text).toBe("streamed-result");
    expect(fakeStream.finalResponse).toHaveBeenCalledTimes(1);
  });

  it("extracts text from output[].content[] when output_text is undefined (streamed path)", async () => {
    // SDK's `responses.stream().finalResponse()` returns a Response where
    // `output_text` is undefined even when text is present in the
    // structured `output[].content[]` array. The provider must dig into
    // that structure rather than returning empty text.
    const create = vi.fn().mockResolvedValue({
      // No output_text accessor (would be undefined on real streamed Response)
      model: "gpt-5",
      usage: { input_tokens: 10, output_tokens: 5 },
      status: "completed",
      output: [
        {
          type: "reasoning",
          summary: "internal reasoning",
        },
        {
          type: "message",
          content: [
            { type: "output_text", text: "cube(10);" },
          ],
        },
      ],
    });
    const provider = createOpenaiProvider({ create });
    const r = await provider.complete({ prompt: "p", model: "gpt-5" });
    expect(r.text).toBe("cube(10);");
  });

  it("translates ChatMessage[] with image into Responses input array", async () => {
    const create = vi.fn().mockResolvedValue(fakeResp());
    const provider = createOpenaiProvider({ create });
    const png = Buffer.from([0x89, 0x50, 0x4e, 0x47]);
    await provider.complete({
      messages: [
        { role: "user", content: "first turn" },
        { role: "assistant", content: "cube();" },
        {
          role: "user",
          content: [
            { type: "text", text: "see this" },
            { type: "image", mediaType: "image/png", data: png },
          ],
        },
      ],
      model: "gpt-5",
    });
    const call = create.mock.calls[0]?.[0];
    expect(call.input).toEqual([
      { role: "user", content: "first turn" },
      { role: "assistant", content: "cube();" },
      {
        role: "user",
        content: [
          { type: "input_text", text: "see this" },
          {
            type: "input_image",
            detail: "auto",
            image_url: `data:image/png;base64,${png.toString("base64")}`,
          },
        ],
      },
    ]);
  });
});
