import { modelSupportsVision } from "../capabilities.js";
import { extractScad } from "../extract.js";
import type {
  ChatMessage,
  CompletionRequest,
  CompletionResponse,
} from "../providers/types.js";
import type {
  HarnessContext,
  HarnessLogBare,
  HarnessResult,
  ParentRunContext,
} from "./types.js";
import type { IterationStrategy } from "../schema.js";

/** ChatContentPart の `mediaType` は今のところ png/jpeg のみサポート。
 *  YAML で書かれた画像パスから拡張子で MIME を当てる。 */
function inferImageMimeType(path: string): "image/png" | "image/jpeg" {
  const lower = path.toLowerCase();
  if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
  // PDF / GIF 等に拡張するときはここに分岐を足し、ChatContentPart の
  // mediaType union も拡張する。今は png / jpeg だけを受け付ける。
  return "image/png";
}

const FEEDBACK_PNG_DEFAULT =
  "上の画像はあなたが書いた SCAD を OpenSCAD でレンダリングした結果です。" +
  "元の課題プロンプトと照らし合わせて、形状・寸法・配置に誤りや改善点があれば修正したコードを ```openscad ... ``` で出力してください。" +
  "問題が無ければ同じコードをそのまま再度出力してください。";

const FEEDBACK_ERROR_DEFAULT =
  "あなたが出力した SCAD は OpenSCAD で次のエラーになりました。" +
  "原因を踏まえて修正したコードを ```openscad ... ``` で出力してください。";

function buildFeedbackMessages(
  prompt: string,
  parent: ParentRunContext,
  strategy: IterationStrategy,
): ChatMessage[] {
  // 直前の自分の出力を code-fence 形式で渡す。raw だとモデルが
  // 「自分は code-fence で返さなかったらしい」と勘違いして次のターンで
  // フォーマットを変えがちなので。
  const assistantText = `\`\`\`openscad\n${parent.scad}\n\`\`\``;
  const messages: ChatMessage[] = [
    { role: "user", content: prompt },
    { role: "assistant", content: assistantText },
  ];

  if (strategy.kind === "render-png-feedback" && parent.png) {
    const text = strategy.promptOverride ?? FEEDBACK_PNG_DEFAULT;
    messages.push({
      role: "user",
      content: [
        { type: "text", text },
        { type: "image", mediaType: "image/png", data: parent.png },
      ],
    });
    return messages;
  }

  // error-text-feedback, or render-png-feedback fallback when PNG missing.
  const errBody = parent.errorMessage ?? "(エラー詳細なし)";
  const text =
    strategy.promptOverride ??
    `${FEEDBACK_ERROR_DEFAULT}\n\nエラー:\n${errBody}`;
  messages.push({ role: "user", content: text });
  return messages;
}

export async function runBare(ctx: HarnessContext): Promise<HarnessResult> {
  if (ctx.config.kind !== "bare") {
    throw new Error(`runBare called with non-bare config: ${ctx.config.kind}`);
  }

  const start = performance.now();
  const harnessLog: HarnessLogBare = {
    kind: "bare",
    ...(ctx.config.iteration ? { iteration: ctx.config.iteration } : {}),
  };
  // Self-hosted (LM Studio / Ollama) は publisher / quant 等が後で
  // 追えるよう meta.json に同梱する。クラウド provider は無実装で undefined。
  if (ctx.config.provider.getModelMetadata) {
    try {
      const md = await ctx.config.provider.getModelMetadata(ctx.config.model);
      if (md) harnessLog.modelMetadata = md;
    } catch {
      // メタデータ取得失敗は run 自体を止めない(host が一時的に応答しない等)。
    }
  }
  const finish = (extra: Partial<HarnessResult>): HarnessResult => ({
    durationMs: performance.now() - start,
    harnessLog,
    ...extra,
    status: extra.status ?? "api_error",
  });

  const baseReq: Omit<CompletionRequest, "prompt" | "messages"> = {
    model: ctx.config.model,
    ...(ctx.config.systemPrompt
      ? { systemPrompt: ctx.config.systemPrompt }
      : {}),
    ...(ctx.config.maxTokens ? { maxTokens: ctx.config.maxTokens } : {}),
    ...(ctx.config.modelOptions
      ? { modelOptions: ctx.config.modelOptions }
      : {}),
  };

  // Reject early when the configured strategy needs a capability the model
  // doesn't have — a render-png-feedback iteration on a vision-less model
  // would otherwise blow up at API time with a confusing error.
  if (
    ctx.parent &&
    ctx.config.iteration?.kind === "render-png-feedback" &&
    !modelSupportsVision(ctx.config.model)
  ) {
    return finish({
      status: "api_error",
      errorMessage: `model "${ctx.config.model}" does not support image input; render-png-feedback iteration requires a vision-capable model`,
    });
  }

  // 入力画像付き(vision)タスクは vision-capable モデルだけで走る前提。
  // matrix.ts の expand 段階で非対応モデルは候補から除外しているが、
  // 何かバグった場合のフェイルセーフでここでも 1 度ガードする。
  const hasImages =
    ctx.task.prompt_image_data && ctx.task.prompt_image_data.length > 0;
  if (hasImages && !modelSupportsVision(ctx.config.model)) {
    return finish({
      status: "api_error",
      errorMessage: `model "${ctx.config.model}" does not support image input but task "${ctx.task.id}" has prompt_images`,
    });
  }

  let response: CompletionResponse;
  try {
    if (ctx.parent && ctx.config.iteration) {
      const messages = buildFeedbackMessages(
        ctx.task.prompt,
        ctx.parent,
        ctx.config.iteration,
      );
      response = await ctx.config.provider.complete({ ...baseReq, messages });
    } else if (hasImages) {
      // 単発 vision 呼び出し: text + image の content parts を 1 user
      // メッセージにまとめる。画像は MIME を path から推定。
      const imageParts = (ctx.task.prompt_image_data ?? []).map((buf, i) => {
        const path = ctx.task.prompt_images?.[i] ?? "";
        const mediaType = inferImageMimeType(path);
        return { type: "image" as const, mediaType, data: buf };
      });
      response = await ctx.config.provider.complete({
        ...baseReq,
        messages: [
          {
            role: "user",
            content: [
              { type: "text", text: ctx.task.prompt },
              ...imageParts,
            ],
          },
        ],
      });
    } else {
      response = await ctx.config.provider.complete({
        ...baseReq,
        prompt: ctx.task.prompt,
      });
    }
  } catch (e) {
    return finish({
      status: "api_error",
      errorMessage: (e as Error).message,
    });
  }

  const tokens = response.tokens;
  const modelId = response.modelId;
  const rawResponse = response.text;
  const timing = {
    ...(response.firstTokenMs !== undefined
      ? { firstTokenMs: response.firstTokenMs }
      : {}),
    ...(response.generationMs !== undefined
      ? { generationMs: response.generationMs }
      : {}),
  };

  const scad = extractScad(response.text);
  if (!scad) {
    const stopHint = response.stopReason
      ? ` (stopReason=${response.stopReason})`
      : "";
    const reason = response.text
      ? `no SCAD code block in response${stopHint}`
      : `model returned empty response${stopHint}`;
    return finish({
      status: "no_code",
      errorMessage: reason,
      ...(tokens ? { tokens } : {}),
      ...timing,
      modelId,
      rawResponse,
    });
  }

  try {
    const rendered = await ctx.render(scad);
    return finish({
      status: "success",
      scad,
      stl: rendered.stl,
      png: rendered.png,
      ...(tokens ? { tokens } : {}),
      ...timing,
      modelId,
      rawResponse,
    });
  } catch (e) {
    return finish({
      status: "render_error",
      scad,
      errorMessage: (e as Error).message,
      ...(tokens ? { tokens } : {}),
      ...timing,
      modelId,
      rawResponse,
    });
  }
}
