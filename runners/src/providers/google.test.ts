import { describe, expect, it, vi } from "vitest";
import { createGoogleProvider } from "./google.js";

interface FakeResponse {
  text?: string;
  modelVersion?: string;
  usageMetadata?: {
    promptTokenCount?: number;
    candidatesTokenCount?: number;
  };
  candidates?: Array<{ finishReason?: string }>;
}

function fakeResp(overrides: FakeResponse = {}): FakeResponse {
  return {
    text: "hello",
    modelVersion: "gemini-2.5-flash",
    usageMetadata: { promptTokenCount: 10, candidatesTokenCount: 5 },
    candidates: [{ finishReason: "STOP" }],
    ...overrides,
  };
}

describe("createGoogleProvider", () => {
  it("name is 'google'", () => {
    const provider = createGoogleProvider({ generate: vi.fn() });
    expect(provider.name).toBe("google");
  });

  it("calls generateContent with the model and prompt as a contents string", async () => {
    const generate = vi.fn().mockResolvedValue(fakeResp());
    const provider = createGoogleProvider({ generate });

    await provider.complete({ prompt: "make a cube", model: "gemini-2.5-flash" });

    expect(generate).toHaveBeenCalledTimes(1);
    const call = generate.mock.calls[0]?.[0];
    expect(call.model).toBe("gemini-2.5-flash");
    expect(call.contents).toBe("make a cube");
  });

  it("merges modelOptions.config into the request config (e.g. thinkingConfig)", async () => {
    const generate = vi.fn().mockResolvedValue(fakeResp());
    const provider = createGoogleProvider({ generate });
    await provider.complete({
      prompt: "p",
      model: "gemini-2.5-pro",
      modelOptions: { config: { thinkingConfig: { thinkingBudget: 0 } } },
    });
    const call = generate.mock.calls[0]?.[0];
    expect(call.config?.maxOutputTokens).toBeGreaterThan(0); // defaults preserved
    expect(call.config?.thinkingConfig).toEqual({ thinkingBudget: 0 });
  });

  it("forwards systemPrompt via config.systemInstruction and maxTokens via config.maxOutputTokens", async () => {
    const generate = vi.fn().mockResolvedValue(fakeResp());
    const provider = createGoogleProvider({ generate });

    await provider.complete({
      prompt: "p",
      model: "gemini-2.5-pro",
      systemPrompt: "Be concise.",
      maxTokens: 2048,
    });

    const call = generate.mock.calls[0]?.[0];
    expect(call.config?.systemInstruction).toBe("Be concise.");
    expect(call.config?.maxOutputTokens).toBe(2048);
  });

  it("returns the response text and tokens", async () => {
    const generate = vi.fn().mockResolvedValue(
      fakeResp({
        text: "result-text",
        modelVersion: "gemini-2.5-flash-001",
        usageMetadata: { promptTokenCount: 50, candidatesTokenCount: 25 },
      }),
    );
    const provider = createGoogleProvider({ generate });

    const r = await provider.complete({ prompt: "p", model: "gemini-2.5-flash" });
    expect(r.text).toBe("result-text");
    expect(r.tokens).toEqual({ input: 50, output: 25 });
    expect(r.modelId).toBe("gemini-2.5-flash-001");
    expect(r.stopReason).toBe("STOP");
    expect(r.durationMs).toBeGreaterThanOrEqual(0);
  });

  it("falls back to the requested model id when modelVersion is missing", async () => {
    const r0 = fakeResp();
    delete r0.modelVersion;
    const generate = vi.fn().mockResolvedValue(r0);
    const provider = createGoogleProvider({ generate });

    const r = await provider.complete({ prompt: "p", model: "gemini-2.5-flash" });
    expect(r.modelId).toBe("gemini-2.5-flash");
  });

  it("returns empty text (not throw) when response has no text but has candidates", async () => {
    // e.g. Gemini Pro hits MAX_TOKENS with all output spent on thinking
    const r0 = fakeResp({
      candidates: [{ finishReason: "MAX_TOKENS" }],
    });
    delete r0.text;
    const generate = vi.fn().mockResolvedValue(r0);
    const provider = createGoogleProvider({ generate });
    const r = await provider.complete({ prompt: "p", model: "gemini-2.5-pro" });
    expect(r.text).toBe("");
    expect(r.stopReason).toBe("MAX_TOKENS");
  });

  it("throws when the response has no candidates at all", async () => {
    const r0 = fakeResp({ candidates: [] });
    delete r0.text;
    const generate = vi.fn().mockResolvedValue(r0);
    const provider = createGoogleProvider({ generate });
    await expect(
      provider.complete({ prompt: "p", model: "gemini-2.5-flash" }),
    ).rejects.toThrow(/no candidates/i);
  });

  it("translates ChatMessage[] with image into Gemini Content[] with inlineData", async () => {
    const generate = vi.fn().mockResolvedValue(fakeResp());
    const provider = createGoogleProvider({ generate });
    await provider.complete({
      messages: [
        { role: "user", content: "first turn" },
        { role: "assistant", content: "cube();" },
        {
          role: "user",
          content: [
            { type: "text", text: "look at this render" },
            {
              type: "image",
              mediaType: "image/png",
              data: Buffer.from([0x89, 0x50, 0x4e, 0x47]),
            },
          ],
        },
      ],
      model: "gemini-2.5-flash",
    });
    const call = generate.mock.calls[0]?.[0];
    expect(call.contents).toEqual([
      { role: "user", parts: [{ text: "first turn" }] },
      { role: "model", parts: [{ text: "cube();" }] },
      {
        role: "user",
        parts: [
          { text: "look at this render" },
          {
            inlineData: {
              mimeType: "image/png",
              // 4-byte buffer: PNG magic prefix
              data: Buffer.from([0x89, 0x50, 0x4e, 0x47]).toString("base64"),
            },
          },
        ],
      },
    ]);
  });
});
