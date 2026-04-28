import { extractPdfPagesAsPng, fetchPdfBytes } from "../pdf.js";
import { runBare } from "./bare.js";
import type {
  BareHarnessConfig,
  HarnessContext,
  HarnessResult,
} from "./types.js";

/**
 * `bare` の前段に PDF preprocessing を挟んだだけのハーネス。
 *
 *  1. task.pdf_source.url を取得(disk cache あり)
 *  2. pdftoppm で task.pdf_source.pages を PNG に切り出す
 *  3. それを task.prompt_image_data に詰めて、bare 同形の context で
 *     `runBare` に委譲(provider 呼び出し本体は使い回す)
 *  4. 戻ってきた HarnessResult の harnessLog を `pdf-page` 形に詰め替えて
 *     URL/pages のメタデータを残す(再現性 fingerprint は taskHash 側で
 *     担保しているのでここは観測ログ目的)
 */
export async function runPdfPage(
  ctx: HarnessContext,
): Promise<HarnessResult> {
  if (ctx.config.kind !== "pdf-page") {
    throw new Error(
      `runPdfPage called with non-pdf-page config: ${ctx.config.kind}`,
    );
  }
  const pdfSource = ctx.task.pdf_source;
  if (!pdfSource) {
    return {
      status: "api_error",
      errorMessage: `task "${ctx.task.id}" uses pdf-page harness but has no pdf_source`,
      durationMs: 0,
      harnessLog: {
        kind: "pdf-page",
        ...(ctx.config.iteration ? { iteration: ctx.config.iteration } : {}),
      },
    };
  }

  let pageBuffers: Buffer[];
  try {
    const bytes = await fetchPdfBytes(pdfSource.url);
    pageBuffers = extractPdfPagesAsPng(bytes, pdfSource.pages);
  } catch (e) {
    return {
      status: "api_error",
      errorMessage: `pdf-page preprocessing failed: ${(e as Error).message}`,
      durationMs: 0,
      harnessLog: {
        kind: "pdf-page",
        ...(ctx.config.iteration ? { iteration: ctx.config.iteration } : {}),
        pdfUrl: pdfSource.url,
        pages: pdfSource.pages,
      },
    };
  }

  const derivedTask = {
    ...ctx.task,
    prompt_image_data: pageBuffers,
    // bare 内 inferImageMimeType は path 拡張子を見るので、合成 .png
    // 名を渡しておけば PNG として送られる。
    prompt_images: pdfSource.pages.map((p) => `pdf-page-${p}.png`),
  };
  const derivedConfig: BareHarnessConfig = {
    kind: "bare",
    provider: ctx.config.provider,
    model: ctx.config.model,
    ...(ctx.config.systemPrompt
      ? { systemPrompt: ctx.config.systemPrompt }
      : {}),
    ...(ctx.config.maxTokens ? { maxTokens: ctx.config.maxTokens } : {}),
    ...(ctx.config.modelOptions
      ? { modelOptions: ctx.config.modelOptions }
      : {}),
    ...(ctx.config.iteration ? { iteration: ctx.config.iteration } : {}),
  };
  const result = await runBare({
    ...ctx,
    task: derivedTask,
    config: derivedConfig,
  });

  return {
    ...result,
    harnessLog: {
      kind: "pdf-page",
      ...(ctx.config.iteration ? { iteration: ctx.config.iteration } : {}),
      pdfUrl: pdfSource.url,
      pages: pdfSource.pages,
    },
  };
}
