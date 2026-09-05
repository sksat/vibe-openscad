/**
 * Per-model capability flags. Used by harnesses to bail out early when a
 * configured iteration strategy requires a capability the target model
 * doesn't have (e.g. render-png-feedback on a vision-less model).
 *
 * Provider-level guards are too coarse — within one provider, different
 * models have different capabilities (e.g. OpenAI o1 has no vision but
 * o3 / o4-mini / gpt-4.1 / gpt-5 family do). 個々のモデルの可否は
 * `models.yml` の `vision:` に持たせてあり、ここはその参照層。
 */
import { resolveModel } from "./models.js";

export function modelSupportsVision(model: string, provider?: string): boolean {
  return resolveModel(model, provider)?.vision === true;
}
