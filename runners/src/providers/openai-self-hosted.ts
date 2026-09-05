/**
 * セルフホスト OpenAI 互換 endpoint 用 provider。
 * Ollama / LM Studio / llama.cpp / vLLM など、`/v1/chat/completions` と
 * `/v1/models` を提供する任意のランタイムを「OpenAI と同じ pipeline」
 * で扱う。クラウド OpenAI(`provider: openai`)と区別するため
 * `provider: openai-self-hosted` と命名。
 *
 * Ollama 本体は `/api/chat` の native API も持つが、LM Studio 等は
 * 標準で OpenAI 互換のみ提供のため、最大公約数として /v1 を使う。
 *
 * Base URL 解決:
 * - `OPENAI_SELF_HOSTED_BASE_URL` 環境変数を最優先
 *   (例: `http://asuha:1234/v1`、末尾 `/v1` 込みで設定)
 * - フォールバック: 旧 `OLLAMA_HOST` 環境変数があればそれに `/v1` を付ける
 * - 無ければ `http://127.0.0.1:11434/v1`(Ollama 既定の /v1 互換)
 *
 * 画像入力(vision):
 * - OpenAI 互換の `{ type: "image_url", image_url: { url: "data:...;base64,..." } }`
 *   形式で渡す。vision 対応モデル(llava, qwen2-vl 等)が認識する
 *
 * 注意: ローカル LLM は VRAM ボトルネックなので bench-config の
 * `defaults.concurrency.perProvider.openai-self-hosted` を 1 に絞ることを
 * 推奨。
 */
import OpenAI from "openai";
import type {
  ChatCompletionCreateParamsNonStreaming,
  ChatCompletionMessageParam,
} from "openai/resources/chat/completions";
import type {
  ChatMessage,
  CompletionRequest,
  CompletionResponse,
  HostInfo,
  ModelMetadata,
  Provider,
} from "./types.js";

/**
 * LM Studio の WebSocket RPC `surveyHardware` を呼んでホスト機の GPU /
 * CPU / RAM を取得する。LM Studio は内部で llama.cpp engine ごとに
 * survey を持っており、`type: "selected"` で現在選択中 engine の結果が
 * 返る。失敗時は undefined(LM Studio 以外の自前 OpenAI 互換サーバ等で
 * /runtime namespace が無い、認証拒否、タイムアウト等)。
 *
 * **hostname は返り値に含めない**。GPU 名と VRAM など、ベンチ結果の
 * 解釈に使うハードウェア情報だけを返す。
 */
export async function surveyLMStudioHardware(
  baseUrl: string,
  opts: { timeoutMs?: number } = {},
): Promise<HostInfo | undefined> {
  const timeoutMs = opts.timeoutMs ?? 5000;
  const wsUrl = baseUrl
    .replace(/\/v1\/?$/, "")
    .replace(/^http/, "ws") + "/runtime";
  return new Promise<HostInfo | undefined>((resolve) => {
    let ws: WebSocket;
    try {
      ws = new WebSocket(wsUrl);
    } catch {
      resolve(undefined);
      return;
    }
    const timer = setTimeout(() => {
      try {
        ws.close();
      } catch {
        /* ignore */
      }
      resolve(undefined);
    }, timeoutMs);
    const done = (info: HostInfo | undefined) => {
      clearTimeout(timer);
      try {
        ws.close();
      } catch {
        /* ignore */
      }
      resolve(info);
    };
    ws.addEventListener("open", () => {
      ws.send(
        JSON.stringify({
          type: "authenticate",
          authVersion: 1,
          clientIdentifier: "vibe-openscad-bench",
          clientPasskey: "vibe-openscad-bench",
        }),
      );
    });
    ws.addEventListener("message", (ev) => {
      let msg: unknown;
      try {
        msg = JSON.parse(typeof ev.data === "string" ? ev.data : "");
      } catch {
        return;
      }
      const obj = msg as { success?: boolean; type?: string; result?: unknown };
      if (obj.success === true && obj.type === undefined) {
        // auth ok → call surveyHardware
        ws.send(
          JSON.stringify({
            type: "rpcCall",
            callId: 1,
            endpoint: "surveyHardware",
            parameter: { type: "selected" },
          }),
        );
        return;
      }
      if (obj.type === "rpcResult") {
        done(parseHardwareSurvey(obj.result));
      }
    });
    ws.addEventListener("error", () => done(undefined));
    ws.addEventListener("close", () => done(undefined));
  });
}

/** surveyHardware 応答から HostInfo を抜き出す。LM Studio は engines の
 *  配列を返し、各 engine が hardwareSurvey を持つ。最初に成功している
 *  engine の値を採用する。GPU が複数あれば 1 台目だけ採る。 */
export function parseHardwareSurvey(result: unknown): HostInfo | undefined {
  const r = result as
    | {
        engines?: Array<{
          hardwareSurvey?: {
            cpuSurveyResult?: {
              cpuInfo?: { name?: string };
            };
            gpuSurveyResult?: {
              gpuInfo?: Array<{
                name?: string;
                dedicatedMemoryCapacityBytes?: number;
                detectionPlatform?: string;
              }>;
            };
          };
          // memoryInfo は engine 直下(hardwareSurvey の外)で返ってくる。
          memoryInfo?: { ramCapacity?: number };
        }>;
      }
    | undefined;
  if (!r?.engines || r.engines.length === 0) return undefined;
  for (const eng of r.engines) {
    const hs = eng.hardwareSurvey;
    if (!hs && !eng.memoryInfo) continue;
    const out: HostInfo = {};
    const gpu0 = hs?.gpuSurveyResult?.gpuInfo?.[0];
    if (gpu0?.name) out.gpu = gpu0.name;
    if (typeof gpu0?.dedicatedMemoryCapacityBytes === "number") {
      out.vramGb = Math.round(gpu0.dedicatedMemoryCapacityBytes / 1024 ** 3);
    }
    if (gpu0?.detectionPlatform) out.gpuPlatform = gpu0.detectionPlatform;
    if (hs?.cpuSurveyResult?.cpuInfo?.name) {
      out.cpu = hs.cpuSurveyResult.cpuInfo.name;
    }
    if (typeof eng.memoryInfo?.ramCapacity === "number") {
      out.memGb = Math.round(eng.memoryInfo.ramCapacity / 1024 ** 3);
    }
    if (Object.keys(out).length === 0) continue;
    return out;
  }
  return undefined;
}

/**
 * `OPENAI_SELF_HOSTED_BASE_URL` をそのまま、無ければ旧来の `OLLAMA_HOST`
 * を /v1 に補正、両方無ければ ollama 既定 + /v1 を返す。末尾の `/` は
 * caller 側で正規化。
 */
export function resolveSelfHostedBaseUrl(
  env: NodeJS.ProcessEnv = process.env,
): string {
  const explicit = env["OPENAI_SELF_HOSTED_BASE_URL"];
  if (explicit) return explicit;
  const legacy = env["OLLAMA_HOST"];
  if (legacy) {
    return legacy.replace(/\/$/, "") + "/v1";
  }
  return "http://127.0.0.1:11434/v1";
}
function defaultBaseUrl(): string {
  return resolveSelfHostedBaseUrl();
}

/**
 * provider 共通形式 → OpenAI ChatCompletion 形式に変換。
 * - text + image を持つ user メッセージは content array にする(`{type:"text"}`
 *   と `{type:"image_url", image_url:{url:"data:.."}}` を混ぜる)
 * - assistant は plain text のみ想定(現状の harness と一致)
 */
function toOpenAIMessages(
  messages: ChatMessage[],
): ChatCompletionMessageParam[] {
  return messages.map<ChatCompletionMessageParam>((m) => {
    if (m.role === "assistant") {
      return { role: "assistant", content: m.content };
    }
    if (typeof m.content === "string") {
      return { role: "user", content: m.content };
    }
    const parts = m.content.map((p) => {
      if (p.type === "text") return { type: "text" as const, text: p.text };
      return {
        type: "image_url" as const,
        image_url: {
          url: `data:${p.mediaType};base64,${p.data.toString("base64")}`,
        },
      };
    });
    return { role: "user", content: parts };
  });
}

export interface OpenAISelfHostedProviderDeps {
  /** OpenAI SDK client(テスト時は mock を inject)。 */
  client?: OpenAI;
  /**
   * 指定 context 長でモデルをロードし直す手段。省略時は LM Studio の
   * WebSocket RPC を使う(テスト時は mock を inject)。
   */
  loadModel?: (modelKey: string, contextLength: number) => Promise<void>;
  /** Base URL override(env より優先)。`/v1` まで含めて指定。 */
  baseURL?: string;
  /** API key。LM Studio / Ollama 双方ダミーで通る。 */
  apiKey?: string;
}

/**
 * 1 リクエストの上限(30 分)。ローカル生成は遅い。実測で qwen3-32b の
 * tier-2 offset-handle-mug が 796.9 秒(13 分)かかった。Anthropic の
 * ストリーミング(STREAM_TIMEOUT_MS)と同じ 30 分に揃える。
 *
 * リトライは 0 にする。相手は自分のローカル endpoint なので、この時間返って
 * こない時点でサーバかコネクションが詰まっており、同じ長い生成をもう一度
 * 投げても待ち時間が伸びるだけになる。落として `api_error` にし、次の候補へ
 * 進めたほうがよい。
 */
const REQUEST_TIMEOUT_MS = 30 * 60 * 1000;


/** `/api/v0/models` から現在のロード幅を読む。未ロード / 不明なら undefined。 */
async function readLoadedContextLength(
  baseURL: string,
  model: string,
): Promise<number | undefined> {
  const hostRoot = baseURL.replace(/\/(v1|api\/v0)$/, "");
  const res = await fetch(`${hostRoot}/api/v0/models`, {
    signal: AbortSignal.timeout(10000),
  });
  if (!res.ok) {
    throw new Error(
      `openai-self-hosted: /api/v0/models が ${res.status} を返したため ` +
        `context_length を確認できない`,
    );
  }
  const body = (await res.json()) as {
    data?: { id?: string; loaded_context_length?: number }[];
  };
  return body.data?.find((m) => m.id === model)?.loaded_context_length;
}

/**
 * 宣言した context 長でモデルが載っている状態にしてから返る。
 *
 * コンテキスト長は **モデルの性質ではなくロード時の設定**。GGUF に書かれた
 * 上限(`max_context_length`)以下なら任意の値でロードでき、LM Studio は VRAM
 * を抑えるため控えめな既定値を使う。同じモデルでもロードのしかたで出力が途中で
 * 切れるかどうかが変わるので、実行条件として fingerprint に載せる
 * (bench-config の `modelOptions.context_length`)。
 *
 * ずれていればロードし直す。ロードしても宣言どおりにならなければ、その条件では
 * 走らせずに落とす。8192 で走った run が 32768 の signature で残るのを防ぐ。
 *
 * **生成の前**に済ませる。後から突き合わせても、条件が違うと分かった時点で
 * 数分かけた生成が無駄になる。
 */
async function ensureLoadedContextLength(
  baseURL: string,
  model: string,
  declared: number,
  loadModel: (modelKey: string, contextLength: number) => Promise<void>,
): Promise<void> {
  if ((await readLoadedContextLength(baseURL, model)) === declared) return;
  await loadModel(model, declared);
  const loaded = await readLoadedContextLength(baseURL, model);
  if (loaded !== declared) {
    throw new Error(
      `openai-self-hosted: ${model} を context ${declared} でロードできない ` +
        `(現在 ${loaded ?? "不明"})。VRAM 不足か、LM Studio 以外の runtime の ` +
        `可能性がある`,
    );
  }
}

/** `/llm` namespace に繋いで認証まで済ませる。認証の作法は surveyHardware と同じ。 */
function connectLlmNamespace(
  baseUrl: string,
  timeoutMs: number,
  onReady: (ws: WebSocket) => void,
  onMessage: (obj: Record<string, unknown>, done: (err?: Error) => void) => void,
): Promise<void> {
  const wsUrl =
    baseUrl.replace(/\/(v1|api\/v0)\/?$/, "").replace(/^http/, "ws") + "/llm";
  return new Promise<void>((resolve, reject) => {
    let ws: WebSocket;
    try {
      ws = new WebSocket(wsUrl);
    } catch (e) {
      reject(e);
      return;
    }
    const done = (err?: Error) => {
      clearTimeout(timer);
      try {
        ws.close();
      } catch {
        /* ignore */
      }
      if (err) reject(err);
      else resolve();
    };
    const timer = setTimeout(
      () => done(new Error(`${wsUrl}: timed out after ${timeoutMs}ms`)),
      timeoutMs,
    );
    ws.addEventListener("open", () => {
      ws.send(
        JSON.stringify({
          type: "authenticate",
          authVersion: 1,
          clientIdentifier: "vibe-openscad-bench",
          clientPasskey: "vibe-openscad-bench",
        }),
      );
    });
    ws.addEventListener("message", (ev) => {
      let msg: unknown;
      try {
        msg = JSON.parse(typeof ev.data === "string" ? ev.data : "");
      } catch {
        return;
      }
      const obj = msg as Record<string, unknown>;
      if (obj["success"] === true && obj["type"] === undefined) {
        onReady(ws);
        return;
      }
      onMessage(obj, done);
    });
    ws.addEventListener("error", () =>
      done(new Error(`${wsUrl}: WebSocket error`)),
    );
  });
}

/**
 * LM Studio からモデルを降ろす。既にロード済みなら必ず先に呼ぶ必要がある
 * (理由は loadLMStudioModel を参照)。未ロード等で失敗しても無視してよい。
 */
export async function unloadLMStudioModel(
  baseUrl: string,
  modelKey: string,
  opts: { timeoutMs?: number } = {},
): Promise<void> {
  await connectLlmNamespace(
    baseUrl,
    opts.timeoutMs ?? 60_000,
    (ws) =>
      ws.send(
        JSON.stringify({
          type: "rpcCall",
          callId: 1,
          endpoint: "unloadModel",
          parameter: { identifier: modelKey },
        }),
      ),
    (obj, done) => {
      if (obj["type"] === "rpcResult") done();
      else done(new Error(`unloadModel: ${JSON.stringify(obj).slice(0, 200)}`));
    },
  );
}

/**
 * LM Studio の WebSocket RPC で、指定 context 長でモデルをロードする。
 *
 * REST(`/api/v0`)側にロード用の endpoint は無く、これは WS だけの機能。
 * `/llm` namespace の `loadModel` channel に、`apiOverride` レイヤとして
 * `llm.load.contextLength` を渡す。
 *
 * **呼ぶ前に unloadLMStudioModel が要る**。既にロード済みのモデルに loadModel を
 * 送っても既存のインスタンスがそのまま返り、context 長は変わらない(実測: 8192 で
 * 載っている qwen3-32b に 32768 を指定しても 8192 のままだった)。
 *
 * unload と load は接続を分けている。1 本にまとめられない理由は確認できていない
 * (まとめた実装が止まったことはあるが、そのときホスト機が再起動していたので
 * 原因を切り分けられていない)。分けたほうが状態を持たずに済むのでこの形にする。
 *
 * LM Studio 以外の runtime(Ollama / vLLM / llama.cpp server)には無い機能なので、
 * その場合は失敗する。呼び出し側が「ロードできない」として扱う。
 */
export async function loadLMStudioModel(
  baseUrl: string,
  modelKey: string,
  contextLength: number,
  opts: { timeoutMs?: number } = {},
): Promise<void> {
  await connectLlmNamespace(
    baseUrl,
    opts.timeoutMs ?? 10 * 60 * 1000,
    (ws) =>
      ws.send(
        JSON.stringify({
          type: "channelCreate",
          channelId: 1,
          endpoint: "loadModel",
          creationParameter: {
            modelKey,
            loadConfigStack: {
              layers: [
                {
                  layerName: "apiOverride",
                  config: {
                    fields: [
                      { key: "llm.load.contextLength", value: contextLength },
                    ],
                  },
                },
              ],
            },
          },
        }),
      ),
    (obj, done) => {
      const inner = (obj["message"] as { type?: string } | undefined)?.type;
      if (inner === "success") done();
      else if (inner === "error")
        done(new Error(`loadModel failed: ${JSON.stringify(obj["message"])}`));
      else if (obj["type"] === "communicationWarning")
        done(new Error(`loadModel rejected: ${JSON.stringify(obj)}`));
    },
  );
}

/** unload → load。ensureLoadedContextLength の既定の実装。 */
async function reloadLMStudioModel(
  baseUrl: string,
  modelKey: string,
  contextLength: number,
): Promise<void> {
  try {
    await unloadLMStudioModel(baseUrl, modelKey);
  } catch {
    // 未ロードなら unload は失敗する。そのまま load へ進む。
  }
  await loadLMStudioModel(baseUrl, modelKey, contextLength);
}

/**
 * STREAMING_NOTE — セルフホストはストリーミングで受ける。
 *
 * Node の fetch(undici)は `headersTimeout` が既定 300 秒。非ストリーミングだと
 * 生成が終わるまでレスポンスヘッダが返らないので、5 分を超える run は SDK に何秒
 * 渡しても undici が先に接続を切る。素の fetch に 900 秒の AbortSignal を付けて
 * 直接投げても 300.7 秒で `fetch failed` になった。qwen3-32b の tier-2 以降は
 * 5 分を超えるため、非ストリーミングでは記録そのものが取れない。
 *
 * ストリーミングならヘッダが即座に返り、chunk が届き続けるかぎり body も切られない。
 *
 * SDK が非ストリーミングの応答(テストのモック等)を返した場合はそのまま通す。
 */
async function collectStream(
  raw: unknown,
): Promise<{
  choices: { message?: { content?: string }; finish_reason?: string }[];
  model?: string;
  usage?: { prompt_tokens: number; completion_tokens: number };
  stats?: LMStudioStats;
}> {
  const iterable = raw as AsyncIterable<unknown> & { choices?: unknown };
  if (typeof iterable?.[Symbol.asyncIterator] !== "function") {
    return raw as never;
  }
  let text = "";
  let finishReason: string | undefined;
  let model: string | undefined;
  let usage: { prompt_tokens: number; completion_tokens: number } | undefined;
  let stats: LMStudioStats | undefined;
  for await (const chunk of iterable) {
    const c = chunk as {
      model?: string;
      usage?: { prompt_tokens: number; completion_tokens: number };
      stats?: LMStudioStats;
      choices?: { delta?: { content?: string }; finish_reason?: string }[];
    };
    if (c.model) model = c.model;
    if (c.usage) usage = c.usage;
    if (c.stats) stats = c.stats;
    for (const ch of c.choices ?? []) {
      if (ch.delta?.content) text += ch.delta.content;
      if (ch.finish_reason) finishReason = ch.finish_reason;
    }
  }
  return {
    choices: [
      {
        message: { content: text },
        ...(finishReason ? { finish_reason: finishReason } : {}),
      },
    ],
    ...(model ? { model } : {}),
    ...(usage ? { usage } : {}),
    ...(stats ? { stats } : {}),
  };
}

export function createOpenAISelfHostedProvider(
  deps: OpenAISelfHostedProviderDeps = {},
): Provider {
  const baseURL = (deps.baseURL ?? defaultBaseUrl()).replace(/\/$/, "");
  // ★ LM Studio は OpenAI 互換 `/v1/chat/completions` も受け付けるが、
  //   その場合 `stats` 等のレスポンス拡張が空になる(generation_time /
  //   time_to_first_token が取れない)。対して LM Studio 独自の
  //   `/api/v0/chat/completions` は同じリクエストで stats を埋めて返す。
  //   --- 起動時に `/api/v0/models` を probe して LM Studio なら
  //   baseURL を `/api/v0` に差し替える(他 runtime — Ollama / vLLM /
  //   llama.cpp server — は probe が失敗するので `/v1` のまま)。
  //   probe は最初の complete() 呼び出しで lazy 実行 → 1 プロセス内で
  //   1 回だけ。
  let clientPromise: Promise<OpenAI> | null = null;
  const getClient = (): Promise<OpenAI> => {
    if (deps.client) return Promise.resolve(deps.client);
    if (clientPromise) return clientPromise;
    clientPromise = (async () => {
      const apiKey = deps.apiKey ?? "self-hosted";
      const hostRoot = baseURL.replace(/\/v1$/, "");
      try {
        const res = await fetch(`${hostRoot}/api/v0/models`, {
          signal: AbortSignal.timeout(2000),
        });
        if (res.ok) {
          return new OpenAI({ baseURL: `${hostRoot}/api/v0`, apiKey });
        }
      } catch {
        // not LM Studio (or unreachable) → fall through
      }
      return new OpenAI({ baseURL, apiKey });
    })();
    return clientPromise;
  };
  return {
    name: "openai-self-hosted",
    async complete(req: CompletionRequest): Promise<CompletionResponse> {
      const start = performance.now();
      const messages: ChatCompletionMessageParam[] = [];
      if (req.systemPrompt) {
        messages.push({ role: "system", content: req.systemPrompt });
      }
      if (req.prompt !== undefined) {
        messages.push({ role: "user", content: req.prompt });
      } else if (req.messages) {
        messages.push(...toOpenAIMessages(req.messages));
      } else {
        throw new Error(
          "openai-self-hosted: prompt or messages must be provided",
        );
      }
      // context_length はサーバのロード条件であってリクエストのパラメータ
      // ではない。fingerprint に載せるために modelOptions へ書くので、
      // ここで抜いてから残りを渡す。
      const { context_length: declaredContext, ...modelOptions } =
        (req.modelOptions ?? {}) as Record<string, unknown> & {
          context_length?: unknown;
        };
      const params = {
        model: req.model,
        messages,
        // ローカル LLM 側 max_tokens は実装によって名前が違う(num_predict
        // 等)。modelOptions に `max_tokens` を入れて override する想定。
        ...modelOptions,
        // ストリーミングで受ける。理由は STREAMING_NOTE を参照。
        stream: true,
        // 既定ではストリーミング応答に usage が乗らない。明示的に要求する。
        stream_options: { include_usage: true },
      } as unknown as ChatCompletionCreateParamsNonStreaming;
      const client = await getClient();
      if (typeof declaredContext === "number") {
        await ensureLoadedContextLength(
          baseURL,
          req.model,
          declaredContext,
          deps.loadModel ?? reloadLMStudioModel.bind(null, baseURL),
        );
      }
      const raw = await client.chat.completions.create(params, {
        timeout: REQUEST_TIMEOUT_MS,
        maxRetries: 0,
      });
      const res = await collectStream(raw);
      const choice = res.choices[0];
      const out: CompletionResponse = {
        text: choice?.message?.content ?? "",
        modelId: res.model ?? req.model,
        durationMs: performance.now() - start,
        ...(choice?.finish_reason ? { stopReason: choice.finish_reason } : {}),
      };
      if (res.usage) {
        out.tokens = {
          input: res.usage.prompt_tokens,
          output: res.usage.completion_tokens,
        };
      }
      // LM Studio は OpenAI-compat レスポンスに非標準の `stats` を足して
      // 返してくる(`tokens_per_second` は wallclock じゃなく純粋な生成
      // throughput、`time_to_first_token` は秒、`generation_time` も秒)。
      // load + prompt-eval + 生成 + network の塊である wallclock の
      // `durationMs` と区別するため、別フィールドとして引っ張り出す。
      const stats = (res as unknown as { stats?: LMStudioStats }).stats;
      if (stats) {
        if (typeof stats.time_to_first_token === "number") {
          out.firstTokenMs = stats.time_to_first_token * 1000;
        }
        if (typeof stats.generation_time === "number") {
          out.generationMs = stats.generation_time * 1000;
        }
      }
      return out;
    },
    /**
     * 量子化や publisher などの情報を取得して run.meta.json に同梱する
     * ため、host の `/api/v0/models` (LM Studio native) → `/api/tags`
     * (Ollama) の順で問い合わせて、対象モデル id にマッチするエントリを
     * `ModelMetadata` 形に正規化して返す。`/v1/models` だけしか応答しない
     * 環境では `null`(取れる情報が id しか無いので意味が無い)。
     *
     * 結果はプロセス内でメモ化する(同 model を 1 run 中に何度叩いても
     * 1 回だけ HTTP を打つ)。
     */
    async getModelMetadata(model: string): Promise<ModelMetadata | null> {
      const cached = metadataCache.get(`${baseURL}::${model}`);
      if (cached !== undefined) return cached;
      // model metadata と hardware survey を並列で取る。後者は LM Studio
      // 以外の自前 OpenAI 互換サーバでは undefined。
      const [md, host] = await Promise.all([
        fetchModelMetadata(baseURL, model),
        surveyLMStudioHardware(baseURL).catch(() => undefined),
      ]);
      const merged: ModelMetadata | null =
        md ?? (host ? { host } : null);
      if (merged && host) merged.host = host;
      metadataCache.set(`${baseURL}::${model}`, merged);
      return merged;
    },
  };
}

/** プロセス内 LRU 代わりの単純 Map。base URL × model 単位でキャッシュ。 */
const metadataCache = new Map<string, ModelMetadata | null>();

/** LM Studio が OpenAI-compat レスポンスに付加する非標準の `stats`。 */
interface LMStudioStats {
  tokens_per_second?: number;
  time_to_first_token?: number;
  generation_time?: number;
  stop_reason?: string;
}

interface LMStudioModelEntry {
  id: string;
  type?: string;
  publisher?: string;
  arch?: string;
  quantization?: string;
  state?: string;
  max_context_length?: number;
  capabilities?: string[];
}
interface OllamaTag {
  name: string;
  model?: string;
  size?: number;
  details?: {
    parameter_size?: string;
    quantization_level?: string;
    family?: string;
  };
}

async function fetchModelMetadata(
  baseURL: string,
  model: string,
): Promise<ModelMetadata | null> {
  const hostRoot = baseURL.replace(/\/v1$/, "");
  // Try LM Studio native first.
  try {
    const res = await fetch(`${hostRoot}/api/v0/models`);
    if (res.ok) {
      const json = (await res.json()) as { data?: LMStudioModelEntry[] };
      const hit = (json.data ?? []).find((m) => m.id === model);
      if (hit) {
        const md: ModelMetadata = { raw: hit as unknown as Record<string, unknown> };
        if (hit.publisher) md.publisher = hit.publisher;
        if (hit.type) md.type = hit.type;
        if (hit.arch) md.arch = hit.arch;
        if (hit.quantization) md.quantization = hit.quantization;
        if (typeof hit.max_context_length === "number")
          md.maxContextLength = hit.max_context_length;
        if (hit.capabilities && hit.capabilities.length > 0)
          md.capabilities = hit.capabilities;
        return md;
      }
    }
  } catch {
    // ignore, fall through
  }
  // Fallback: Ollama native /api/tags
  try {
    const res = await fetch(`${hostRoot}/api/tags`);
    if (res.ok) {
      const json = (await res.json()) as { models?: OllamaTag[] };
      const hit = (json.models ?? []).find(
        (m) => m.name === model || m.model === model,
      );
      if (hit) {
        const md: ModelMetadata = { raw: hit as unknown as Record<string, unknown> };
        if (hit.details?.family) md.arch = hit.details.family;
        if (hit.details?.quantization_level)
          md.quantization = hit.details.quantization_level;
        if (hit.details?.parameter_size)
          md.parameterSize = hit.details.parameter_size;
        if (typeof hit.size === "number") md.size = hit.size;
        return md;
      }
    }
  } catch {
    // ignore
  }
  return null;
}
