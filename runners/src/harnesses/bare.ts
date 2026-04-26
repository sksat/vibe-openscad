import { extractScad } from "../extract.js";
import type { CompletionResponse } from "../providers/types.js";
import type { HarnessContext, HarnessResult } from "./types.js";

export async function runBare(ctx: HarnessContext): Promise<HarnessResult> {
  if (ctx.config.kind !== "bare") {
    throw new Error(`runBare called with non-bare config: ${ctx.config.kind}`);
  }

  const start = performance.now();
  const harnessLog = { kind: "bare" as const };
  const finish = (extra: Partial<HarnessResult>): HarnessResult => ({
    durationMs: performance.now() - start,
    harnessLog,
    ...extra,
    status: extra.status ?? "api_error",
  });

  let response: CompletionResponse;
  try {
    response = await ctx.config.provider.complete({
      prompt: ctx.task.prompt,
      model: ctx.config.model,
      ...(ctx.config.systemPrompt
        ? { systemPrompt: ctx.config.systemPrompt }
        : {}),
      ...(ctx.config.maxTokens ? { maxTokens: ctx.config.maxTokens } : {}),
      ...(ctx.config.modelOptions
        ? { modelOptions: ctx.config.modelOptions }
        : {}),
    });
  } catch (e) {
    return finish({
      status: "api_error",
      errorMessage: (e as Error).message,
    });
  }

  const tokens = response.tokens;
  const modelId = response.modelId;

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
      modelId,
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
      modelId,
    });
  } catch (e) {
    return finish({
      status: "render_error",
      scad,
      errorMessage: (e as Error).message,
      ...(tokens ? { tokens } : {}),
      modelId,
    });
  }
}
