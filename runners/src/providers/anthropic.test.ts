import type Anthropic from "@anthropic-ai/sdk";
import { describe, expect, it, vi } from "vitest";
import { createAnthropicProvider } from "./anthropic.js";

function fakeMessage(
  overrides: Partial<Anthropic.Message> = {},
): Anthropic.Message {
  return {
    id: "msg_test",
    type: "message",
    role: "assistant",
    model: "claude-opus-4-7",
    content: [{ type: "text", text: "hello", citations: null }],
    stop_reason: "end_turn",
    stop_sequence: null,
    usage: {
      input_tokens: 10,
      output_tokens: 20,
      cache_creation_input_tokens: 0,
      cache_read_input_tokens: 0,
      cache_creation: null,
      server_tool_use: null,
      service_tier: "standard",
    },
    ...overrides,
  } as Anthropic.Message;
}

describe("createAnthropicProvider", () => {
  it("name is 'anthropic'", () => {
    const provider = createAnthropicProvider({ create: vi.fn() });
    expect(provider.name).toBe("anthropic");
  });

  it("calls messages.create with the configured model and prompt as a user turn", async () => {
    const create = vi.fn().mockResolvedValue(fakeMessage());
    const provider = createAnthropicProvider({ create });

    await provider.complete({ prompt: "make a cube", model: "claude-opus-4-7" });

    expect(create).toHaveBeenCalledTimes(1);
    const call = create.mock.calls[0]?.[0];
    expect(call).toMatchObject({
      model: "claude-opus-4-7",
      messages: [{ role: "user", content: "make a cube" }],
    });
    expect(typeof call.max_tokens).toBe("number");
  });

  it("does not send temperature/top_p/top_k (Opus 4.7 rejects them)", async () => {
    const create = vi.fn().mockResolvedValue(fakeMessage());
    const provider = createAnthropicProvider({ create });
    await provider.complete({ prompt: "p", model: "claude-opus-4-7" });
    const call = create.mock.calls[0]?.[0];
    expect(call).not.toHaveProperty("temperature");
    expect(call).not.toHaveProperty("top_p");
    expect(call).not.toHaveProperty("top_k");
  });

  it("forwards systemPrompt and maxTokens", async () => {
    const create = vi.fn().mockResolvedValue(fakeMessage());
    const provider = createAnthropicProvider({ create });

    await provider.complete({
      prompt: "p",
      model: "claude-opus-4-7",
      systemPrompt: "Be concise.",
      maxTokens: 4096,
    });

    const call = create.mock.calls[0]?.[0];
    expect(call.system).toBe("Be concise.");
    expect(call.max_tokens).toBe(4096);
  });

  it("returns concatenated text from multiple text blocks and reports tokens", async () => {
    const create = vi.fn().mockResolvedValue(
      fakeMessage({
        content: [
          { type: "text", text: "part-1\n", citations: null },
          { type: "text", text: "part-2", citations: null },
        ],
      }),
    );
    const provider = createAnthropicProvider({ create });

    const r = await provider.complete({
      prompt: "p",
      model: "claude-opus-4-7",
    });

    expect(r.text).toBe("part-1\npart-2");
    expect(r.tokens).toEqual({ input: 10, output: 20 });
    expect(r.modelId).toBe("claude-opus-4-7");
    expect(r.stopReason).toBe("end_turn");
    expect(r.durationMs).toBeGreaterThanOrEqual(0);
  });

  it("throws when the response has no text blocks", async () => {
    const create = vi.fn().mockResolvedValue(
      fakeMessage({
        content: [] as never,
      }),
    );
    const provider = createAnthropicProvider({ create });
    await expect(
      provider.complete({ prompt: "p", model: "claude-opus-4-7" }),
    ).rejects.toThrow(/no text/i);
  });
});
