import { describe, expect, it, vi } from "vitest";
import type OpenAI from "openai";
import {
  createOpenAISelfHostedProvider,
  parseHardwareSurvey,
  resolveSelfHostedBaseUrl,
} from "./openai-self-hosted.js";

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
    const p = createOpenAISelfHostedProvider({ client });
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
    const p = createOpenAISelfHostedProvider({ client });
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
    const p = createOpenAISelfHostedProvider({ client });
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
    const p = createOpenAISelfHostedProvider({ client });
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
    const p = createOpenAISelfHostedProvider({
      client: {
        chat: { completions: { create } },
      } as unknown as OpenAI,
    });
    await expect(p.complete({ prompt: "p", model: "x" })).rejects.toThrow(
      /ECONNREFUSED/,
    );
  });
});

describe("parseHardwareSurvey", () => {
  // 実際に asuha (LM Studio) から surveyHardware で取った応答の最小骨子。
  const ASUHA_SAMPLE = {
    status: "ok",
    engines: [
      {
        name: "llama.cpp-cuda",
        hardwareSurvey: {
          cpuSurveyResult: {
            cpuInfo: {
              name: "12th Gen Intel(R) Core(TM) i9-12900K",
              architecture: "x86_64",
            },
          },
          gpuSurveyResult: {
            gpuInfo: [
              {
                name: "NVIDIA GeForce RTX 3090",
                deviceId: 0,
                totalMemoryCapacityBytes: 42555912192,
                dedicatedMemoryCapacityBytes: 25503465472,
                detectionPlatform: "Vulkan",
              },
              {
                name: "Microsoft Direct3D12 (NVIDIA GeForce RTX 3090)",
                deviceId: 1,
              },
            ],
          },
        },
        // memoryInfo は engine 直下(hardwareSurvey の外)に出る。
        memoryInfo: {
          ramCapacity: 34104893440,
          vramCapacity: 25503465472,
          totalMemory: 59608358912,
        },
      },
    ],
  };

  it("extracts GPU name + dedicated VRAM (GB) from the first engine", () => {
    const info = parseHardwareSurvey(ASUHA_SAMPLE)!;
    expect(info.gpu).toBe("NVIDIA GeForce RTX 3090");
    // 25503465472 / 1024^3 ≈ 23.75 → round to 24
    expect(info.vramGb).toBe(24);
    expect(info.gpuPlatform).toBe("Vulkan");
  });

  it("extracts CPU name and main RAM (GB)", () => {
    const info = parseHardwareSurvey(ASUHA_SAMPLE)!;
    expect(info.cpu).toBe("12th Gen Intel(R) Core(TM) i9-12900K");
    expect(info.memGb).toBe(32); // 34104893440 / 1024^3 ≈ 31.76 → 32
  });

  it("does not include hostname / baseURL / any host identity", () => {
    // ★ meta.json には hostname を残さない契約。survey の output には
    //   GPU/CPU/RAM のハードウェア値だけを含めること。
    const info = parseHardwareSurvey(ASUHA_SAMPLE);
    expect(info).not.toHaveProperty("name");
    expect(info).not.toHaveProperty("baseUrl");
    expect(info).not.toHaveProperty("hostname");
  });

  it("returns undefined for empty / malformed responses", () => {
    expect(parseHardwareSurvey(undefined)).toBeUndefined();
    expect(parseHardwareSurvey({})).toBeUndefined();
    expect(parseHardwareSurvey({ engines: [] })).toBeUndefined();
    expect(parseHardwareSurvey({ engines: [{}] })).toBeUndefined();
  });

  it("falls through to the next engine when the first has no usable hardware fields", () => {
    const sample = {
      engines: [
        { name: "stub", hardwareSurvey: { gpuSurveyResult: {} } },
        {
          name: "real",
          hardwareSurvey: {
            gpuSurveyResult: {
              gpuInfo: [
                {
                  name: "Some GPU",
                  dedicatedMemoryCapacityBytes: 8 * 1024 ** 3,
                },
              ],
            },
          },
        },
      ],
    };
    expect(parseHardwareSurvey(sample)?.gpu).toBe("Some GPU");
  });
});

describe("resolveSelfHostedBaseUrl", () => {
  it("prefers OPENAI_SELF_HOSTED_BASE_URL", () => {
    expect(
      resolveSelfHostedBaseUrl({
        OPENAI_SELF_HOSTED_BASE_URL: "http://asuha:1234/v1",
      }),
    ).toBe("http://asuha:1234/v1");
  });
  it("falls back to OLLAMA_HOST and appends /v1", () => {
    expect(resolveSelfHostedBaseUrl({ OLLAMA_HOST: "http://h:11434" })).toBe(
      "http://h:11434/v1",
    );
    expect(resolveSelfHostedBaseUrl({ OLLAMA_HOST: "http://h:11434/" })).toBe(
      "http://h:11434/v1",
    );
  });
  it("defaults to local ollama when neither env is set", () => {
    expect(resolveSelfHostedBaseUrl({})).toBe("http://127.0.0.1:11434/v1");
  });
});

