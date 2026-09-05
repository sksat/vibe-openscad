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
  it("keeps the non-streaming path at or below the SDK's threshold", async () => {
    // 既存エントリ(max_tokens 4096 / 16000)の転送方式を変えないための境界。
    // ここを動かすと signature は同じまま転送方式だけが変わってしまう。
    const create = vi.fn().mockResolvedValue(fakeMessage());
    const stream = vi.fn();
    const client = { messages: { create, stream } } as unknown as Anthropic;
    const provider = createAnthropicProvider({ client });

    await provider.complete({ prompt: "p", model: "claude-opus-5", maxTokens: 21333 });

    expect(create).toHaveBeenCalledTimes(1);
    expect(stream).not.toHaveBeenCalled();
  });

  it("uses the streaming API above the SDK's non-streaming threshold", async () => {
    // 非ストリーミングの messages.create は max_tokens > 16000 を
    // "Streaming is required for operations that may take longer than
    // 10 minutes" で SDK が弾く。thinking が既定 on のモデル(Sonnet 5 /
    // Opus 5 等)は 16k を思考で使い切って SCAD 到達前に切れるため、
    // 本番経路はストリーミングを使う。
    const finalMessage = vi.fn().mockResolvedValue(fakeMessage());
    const stream = vi.fn().mockReturnValue({ finalMessage });
    const create = vi.fn();
    const client = { messages: { stream, create } } as unknown as Anthropic;
    const provider = createAnthropicProvider({ client });

    const res = await provider.complete({
      prompt: "p",
      model: "claude-sonnet-5",
      maxTokens: 21334,
    });

    expect(stream).toHaveBeenCalledTimes(1);
    expect(create).not.toHaveBeenCalled();
    expect(stream.mock.calls[0]?.[0]).toMatchObject({ max_tokens: 21334 });
    expect(res.text).toBe("hello");
  });

  it("bounds the stream with a finite timeout", async () => {
    // SSE が途中で無音になると finalMessage() は待ち続ける。bench-config の
    // timeoutSec は provider 呼び出しに配線されていないので、ここで上限を
    // 持たせないと 1 件の停止でベンチ全体が終わらなくなる。
    const finalMessage = vi.fn().mockResolvedValue(fakeMessage());
    const stream = vi.fn().mockReturnValue({ finalMessage });
    const client = { messages: { stream } } as unknown as Anthropic;
    const provider = createAnthropicProvider({ client });

    await provider.complete({
      prompt: "p",
      model: "claude-sonnet-5",
      maxTokens: 64000,
    });

    const opts = stream.mock.calls[0]?.[1];
    expect(typeof opts?.timeout).toBe("number");
    expect(opts.timeout).toBeGreaterThan(0);
    expect(Number.isFinite(opts.timeout)).toBe(true);
  });

  it("records the thinking portion of the output tokens", async () => {
    // Anthropic の output_tokens は thinking を含んだ値。内訳は
    // output_tokens_details.thinking_tokens として別に返る。
    const create = vi.fn().mockResolvedValue(
      fakeMessage({
        usage: {
          input_tokens: 10,
          output_tokens: 900,
          output_tokens_details: { thinking_tokens: 700 },
        },
      } as never),
    );
    const provider = createAnthropicProvider({ create });

    const res = await provider.complete({ prompt: "p", model: "claude-opus-5" });

    expect(res.tokens).toEqual({ input: 10, output: 900, thinking: 700 });
  });

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

  it("returns empty text (not throw) when max_tokens is hit before any text block", async () => {
    // Fable 5 など出力の長いモデルは、重いタスクで max_tokens を text block
    // ゼロのまま使い切ることがある。これは「SCAD を返さなかった」観測
    // (no_code)であって precondition 失敗(api_error)ではないので、
    // provider は throw せず空テキストとして返す。
    const create = vi.fn().mockResolvedValue(
      fakeMessage({
        content: [] as never,
        stop_reason: "max_tokens",
      }),
    );
    const provider = createAnthropicProvider({ create });
    const r = await provider.complete({
      prompt: "p",
      model: "claude-fable-5",
    });
    expect(r.text).toBe("");
    expect(r.stopReason).toBe("max_tokens");
    expect(r.tokens).toEqual({ input: 10, output: 20 });
  });
});
