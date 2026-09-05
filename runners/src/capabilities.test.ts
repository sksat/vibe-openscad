import { describe, expect, it } from "vitest";
import { modelSupportsVision } from "./capabilities.js";

/**
 * どのモデルが vision 対応かという **データ** は models.yml にあり、
 * 「bench-config の全モデルが vision を宣言しているか」は models.test.ts の
 * 網羅テストが見る。ここで固定するのは解決規則と、非対応を非対応と
 * 判定できること(誤って true にすると vision タスクで課金を無駄にする)。
 */
describe("modelSupportsVision", () => {
  it("accepts a vision model regardless of date suffix", () => {
    expect(modelSupportsVision("claude-opus-4-7")).toBe(true);
    expect(modelSupportsVision("claude-haiku-4-5-20251001")).toBe(true);
    expect(modelSupportsVision("gpt-5.4-2026-03-05")).toBe(true);
  });

  it("lets a specific variant override its family", () => {
    // o3 は vision 可だが o3-mini は不可。長い prefix が勝つこと。
    expect(modelSupportsVision("o3-2025-04-16")).toBe(true);
    expect(modelSupportsVision("o3-mini")).toBe(false);
  });

  it("rejects models with no vision support", () => {
    expect(modelSupportsVision("o1")).toBe(false);
    expect(modelSupportsVision("o1-2024-12-17")).toBe(false);
    expect(modelSupportsVision("openai/gpt-oss-20b")).toBe(false);
  });

  it("rejects unknown / non-vision strings", () => {
    expect(modelSupportsVision("gpt-3.5-turbo")).toBe(false);
    expect(modelSupportsVision("text-davinci-003")).toBe(false);
    expect(modelSupportsVision("local-llama-7b")).toBe(false);
  });

  it("can be narrowed by provider", () => {
    expect(modelSupportsVision("claude-opus-4-7", "anthropic")).toBe(true);
    expect(modelSupportsVision("claude-opus-4-7", "openai")).toBe(false);
  });
});
