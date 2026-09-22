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

/** ストリーミング応答のモック。chunk を順に流す async iterable を返す。 */
function makeStreamingMockClient(chunks: unknown[]) {
  const create = vi.fn().mockResolvedValue({
    async *[Symbol.asyncIterator]() {
      for (const c of chunks) yield c;
    },
  });
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

  it("bounds the request with a finite timeout and no retries", async () => {
    // openai-node の既定は 1 リクエスト 10 分 + リトライ 2 回。ローカル
    // endpoint が応答を返さないまま固まると 30 分待つ。実測では成功する run
    // は 5 分以内に終わる一方、固まった run は 15 分ずつ溶かした。
    const { client, create } = makeMockClient({
      choices: [{ message: { content: "x" } }],
    });
    const p = createOpenAISelfHostedProvider({ client });

    await p.complete({ prompt: "p", model: "qwen3-32b" });

    const opts = create.mock.calls[0]?.[1];
    expect(typeof opts?.timeout).toBe("number");
    expect(Number.isFinite(opts.timeout)).toBe(true);
    expect(opts.timeout).toBeGreaterThan(0);
    expect(opts.maxRetries).toBe(0);
  });

  it("does not forward modelOptions.context_length to the SDK call", async () => {
    // context_length はサーバのロード条件であってリクエストのパラメータでは
    // ない。fingerprint に載せるために modelOptions に書くが、そのまま
    // /chat/completions へ送っても意味が無いので抜いてから渡す。
    const { client, create } = makeMockClient({
      choices: [{ message: { content: "x" } }],
    });
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: async () => ({
          data: [
            { id: "qwen3-8b", state: "loaded", loaded_context_length: 32768 },
          ],
        }),
      }),
    );
    const p = createOpenAISelfHostedProvider({ client });

    await p.complete({
      prompt: "p",
      model: "qwen3-8b",
      modelOptions: { context_length: 32768, temperature: 0.2 },
    });

    expect(create.mock.calls[0]?.[0]).not.toHaveProperty("context_length");
    expect(create.mock.calls[0]?.[0]).toMatchObject({ temperature: 0.2 });
    vi.unstubAllGlobals();
  });

  it("loads the model at the declared context length when it differs", async () => {
    // 宣言と実態がずれていたら、落とす前にその context でロードし直す。
    // LM Studio の WS RPC (/llm の loadModel channel) が受け付ける。
    const { client } = makeMockClient({
      choices: [{ message: { content: "x" } }],
    });
    let loadedCtx = 8192;
    const loadModel = vi.fn(async (_m: string, ctx: number) => {
      loadedCtx = ctx;
    });
    vi.stubGlobal(
      "fetch",
      vi.fn().mockImplementation(async () => ({
        ok: true,
        json: async () => ({
          data: [
            {
              id: "qwen3-8b",
              state: "loaded",
              loaded_context_length: loadedCtx,
            },
          ],
        }),
      })),
    );
    const p = createOpenAISelfHostedProvider({ client, loadModel });

    const res = await p.complete({
      prompt: "p",
      model: "qwen3-8b",
      modelOptions: { context_length: 32768 },
    });

    expect(loadModel).toHaveBeenCalledWith("qwen3-8b", 32768);
    expect(res.text).toBe("x");
    vi.unstubAllGlobals();
  });

  it("does not reload when the context length already matches", async () => {
    const { client } = makeMockClient({
      choices: [{ message: { content: "x" } }],
    });
    const loadModel = vi.fn();
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: async () => ({
          data: [
            { id: "qwen3-8b", state: "loaded", loaded_context_length: 32768 },
          ],
        }),
      }),
    );
    const p = createOpenAISelfHostedProvider({ client, loadModel });

    await p.complete({
      prompt: "p",
      model: "qwen3-8b",
      modelOptions: { context_length: 32768 },
    });

    expect(loadModel).not.toHaveBeenCalled();
    vi.unstubAllGlobals();
  });

  it("fails when the reload did not take effect", async () => {
    // ロードを試みても宣言どおりにならないなら、その条件では走らせない。
    // 8192 で走った run が 32768 の signature で残るのを防ぐ。
    const { client, create } = makeMockClient({
      choices: [{ message: { content: "x" } }],
    });
    const loadModel = vi.fn().mockResolvedValue(undefined);
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: async () => ({
          data: [
            { id: "qwen3-8b", state: "loaded", loaded_context_length: 8192 },
          ],
        }),
      }),
    );
    const p = createOpenAISelfHostedProvider({ client, loadModel });

    await expect(
      p.complete({
        prompt: "p",
        model: "qwen3-8b",
        modelOptions: { context_length: 32768 },
      }),
    ).rejects.toThrow(/8192.*32768|32768.*8192/);
    // 条件が揃っていないので生成そのものを行わない。
    expect(create).not.toHaveBeenCalled();
    vi.unstubAllGlobals();
  });

  it("skips the context check when context_length is not declared", async () => {
    // 宣言していないエントリは従来どおり。probe も行わない。
    const { client } = makeMockClient({
      choices: [{ message: { content: "x" } }],
    });
    const fetchMock = vi.fn();
    vi.stubGlobal("fetch", fetchMock);
    const p = createOpenAISelfHostedProvider({ client });

    const res = await p.complete({ prompt: "p", model: "qwen3-8b" });

    expect(res.text).toBe("x");
    expect(fetchMock).not.toHaveBeenCalled();
    vi.unstubAllGlobals();
  });

  it("streams the request and concatenates the deltas", async () => {
    // Node の fetch(undici)は headersTimeout が既定 300 秒。非ストリーミング
    // だと生成が終わるまでヘッダが返らないので、5 分を超える run は SDK に
    // 何秒渡しても undici に切られる。ストリーミングならヘッダが即座に返る。
    const { client, create } = makeStreamingMockClient([
      { choices: [{ delta: { content: "cu" } }] },
      { choices: [{ delta: { content: "be(" } }] },
      { choices: [{ delta: { content: "10);" }, finish_reason: "stop" }] },
      {
        choices: [],
        model: "qwen3-32b",
        usage: { prompt_tokens: 12, completion_tokens: 34 },
      },
    ]);
    const p = createOpenAISelfHostedProvider({ client });

    const res = await p.complete({ prompt: "p", model: "qwen3-32b" });

    expect(create.mock.calls[0]?.[0]).toMatchObject({ stream: true });
    expect(res.text).toBe("cube(10);");
    expect(res.stopReason).toBe("stop");
    expect(res.tokens).toEqual({ input: 12, output: 34 });
  });

  it("asks for usage on the stream", async () => {
    // 既定ではストリーミング応答に usage が乗らない。明示的に要求する。
    const { client, create } = makeStreamingMockClient([
      { choices: [{ delta: { content: "x" }, finish_reason: "stop" }] },
    ]);
    const p = createOpenAISelfHostedProvider({ client });

    await p.complete({ prompt: "p", model: "qwen3-32b" });

    expect(create.mock.calls[0]?.[0]).toMatchObject({
      stream_options: { include_usage: true },
    });
  });

  it("survives chunks that carry neither content nor usage", async () => {
    // role だけの先頭 chunk や、空の choices を挟む実装がある。
    const { client } = makeStreamingMockClient([
      { choices: [{ delta: { role: "assistant" } }] },
      { choices: [] },
      { choices: [{ delta: {} }] },
      { choices: [{ delta: { content: "ok" }, finish_reason: "stop" }] },
    ]);
    const p = createOpenAISelfHostedProvider({ client });

    const res = await p.complete({ prompt: "p", model: "qwen3-32b" });

    expect(res.text).toBe("ok");
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

