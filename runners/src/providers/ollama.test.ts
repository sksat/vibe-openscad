import { describe, expect, it, vi } from "vitest";
import type OpenAI from "openai";
import { createOllamaProvider } from "./ollama.js";

/** OpenAI SDK 互換の最小モック client。chat.completions.create の引数を
 *  キャプチャしてレスポンスを返すだけ。 */
function makeMockClient(response: unknown) {
  const create = vi.fn().mockResolvedValue(response);
  return {
    create,
    client: { chat: { completions: { create } } } as unknown as OpenAI,
  };
}

describe("ollama provider (OpenAI-compat /v1/chat/completions)", () => {
  it("invokes chat.completions.create with single-shot prompt + parses tokens/text", async () => {
    const { client, create } = makeMockClient({
      model: "llama3:8b",
      choices: [
        {
          message: { role: "assistant", content: "```openscad\ncube();\n```" },
          finish_reason: "stop",
        },
      ],
      usage: { prompt_tokens: 42, completion_tokens: 17 },
    });
    const p = createOllamaProvider({ client });
    const res = await p.complete({ prompt: "make a cube", model: "llama3:8b" });
    expect(res.text).toContain("cube()");
    expect(res.modelId).toBe("llama3:8b");
    expect(res.tokens).toEqual({ input: 42, output: 17 });
    expect(res.stopReason).toBe("stop");
    expect(create).toHaveBeenCalledTimes(1);
    const params = create.mock.calls[0]![0];
    expect(params.model).toBe("llama3:8b");
    expect(params.messages).toEqual([
      { role: "user", content: "make a cube" },
    ]);
  });

  it("forwards systemPrompt as a leading system message", async () => {
    const { client, create } = makeMockClient({
      model: "x",
      choices: [{ message: { content: "y" }, finish_reason: "stop" }],
    });
    const p = createOllamaProvider({ client });
    await p.complete({ prompt: "p", model: "x", systemPrompt: "you are concise" });
    expect(create.mock.calls[0]![0].messages).toEqual([
      { role: "system", content: "you are concise" },
      { role: "user", content: "p" },
    ]);
  });

  it("translates ChatContentPart messages: text + image_url with base64 data URI", async () => {
    // iter-png-feedback / pdf-page で image を送るとき OpenAI 互換の
    // `image_url: { url: "data:image/png;base64,..." }` 形式に変換する。
    const { client, create } = makeMockClient({
      model: "llava",
      choices: [{ message: { content: "ok" }, finish_reason: "stop" }],
    });
    const p = createOllamaProvider({ client });
    const png = Buffer.from([0x89, 0x50, 0x4e, 0x47]);
    await p.complete({
      model: "llava",
      messages: [
        {
          role: "user",
          content: [
            { type: "text", text: "see this:" },
            { type: "image", mediaType: "image/png", data: png },
          ],
        },
      ],
    });
    const sent = create.mock.calls[0]![0].messages;
    expect(sent).toEqual([
      {
        role: "user",
        content: [
          { type: "text", text: "see this:" },
          {
            type: "image_url",
            image_url: {
              url: `data:image/png;base64,${png.toString("base64")}`,
            },
          },
        ],
      },
    ]);
  });

  it("merges modelOptions(`max_tokens` / `temperature` 等)を flat に渡す", async () => {
    const { client, create } = makeMockClient({
      model: "x",
      choices: [{ message: { content: "y" }, finish_reason: "stop" }],
    });
    const p = createOllamaProvider({ client });
    await p.complete({
      prompt: "p",
      model: "x",
      modelOptions: { max_tokens: 4096, temperature: 0.2 },
    });
    const params = create.mock.calls[0]![0];
    expect(params.max_tokens).toBe(4096);
    expect(params.temperature).toBe(0.2);
  });

  it("propagates SDK errors as-is(host が落ちている等の判別を上位に任せる)", async () => {
    const create = vi.fn().mockRejectedValue(new Error("ECONNREFUSED"));
    const p = createOllamaProvider({
      client: {
        chat: { completions: { create } },
      } as unknown as OpenAI,
    });
    await expect(p.complete({ prompt: "p", model: "x" })).rejects.toThrow(
      /ECONNREFUSED/,
    );
  });
});
