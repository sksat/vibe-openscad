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
