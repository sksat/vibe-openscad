import { describe, expect, it } from "vitest";
import { computeCostUsd, getRate } from "./pricing.js";

describe("getRate", () => {
  it("returns rate for current Anthropic models (alias and dated)", () => {
    expect(getRate("anthropic", "claude-opus-4-7")).toEqual({
      inputPerMtok: 5,
      outputPerMtok: 25,
    });
    expect(getRate("anthropic", "claude-haiku-4-5")).toEqual({
      inputPerMtok: 1,
      outputPerMtok: 5,
    });
    expect(getRate("anthropic", "claude-haiku-4-5-20251001")).toEqual({
      inputPerMtok: 1,
      outputPerMtok: 5,
    });
  });

  it("returns rate for legacy Anthropic models", () => {
    expect(getRate("anthropic", "claude-opus-4-1-20250805")).toEqual({
      inputPerMtok: 15,
      outputPerMtok: 75,
    });
    expect(getRate("anthropic", "claude-sonnet-4-5-20250929")).toEqual({
      inputPerMtok: 3,
      outputPerMtok: 15,
    });
  });

  it("returns null for unknown providers/models", () => {
    expect(getRate("anthropic", "definitely-not-a-model")).toBeNull();
    expect(getRate("nonsuch-provider", "anything")).toBeNull();
    expect(getRate("openai", "wat-is-this")).toBeNull();
  });

  it("returns rate for OpenAI models, longest prefix wins", () => {
    expect(getRate("openai", "gpt-5")).toEqual({
      inputPerMtok: 1.25,
      outputPerMtok: 10,
    });
    expect(getRate("openai", "gpt-5-mini")).toEqual({
      inputPerMtok: 0.25,
      outputPerMtok: 2,
    });
    expect(getRate("openai", "gpt-5-nano")).toEqual({
      inputPerMtok: 0.05,
      outputPerMtok: 0.4,
    });
    expect(getRate("openai", "o3")).toEqual({
      inputPerMtok: 2,
      outputPerMtok: 8,
    });
    // dated snapshots inherit the alias rate via prefix
    expect(getRate("openai", "gpt-5-2025-09-15")).toEqual({
      inputPerMtok: 1.25,
      outputPerMtok: 10,
    });
  });

  it("uses the more specific 5.x family rate, not gpt-5 base", () => {
    // regression: gpt-5.4-mini was hitting the gpt-5 prefix → wrong rate
    expect(getRate("openai", "gpt-5.4-mini-2026-03-17")).toEqual({
      inputPerMtok: 0.4,
      outputPerMtok: 3,
    });
    expect(getRate("openai", "gpt-5.4-nano-2026-03-17")).toEqual({
      inputPerMtok: 0.075,
      outputPerMtok: 0.6,
    });
    expect(getRate("openai", "gpt-5.4-2026-03-05")).toEqual({
      inputPerMtok: 2,
      outputPerMtok: 16,
    });
  });

  it("returns rate for Gemini models", () => {
    expect(getRate("google", "gemini-2.5-pro")).toEqual({
      inputPerMtok: 1.25,
      outputPerMtok: 10,
    });
    expect(getRate("google", "gemini-2.5-flash")).toEqual({
      inputPerMtok: 0.3,
      outputPerMtok: 2.5,
    });
    expect(getRate("google", "gemini-2.5-flash-lite")).toEqual({
      inputPerMtok: 0.1,
      outputPerMtok: 0.4,
    });
  });

  it("matches dated snapshot to its alias rate via prefix", () => {
    // a future snapshot of opus-4-7 should still resolve
    expect(getRate("anthropic", "claude-opus-4-7-20260601")).toEqual({
      inputPerMtok: 5,
      outputPerMtok: 25,
    });
  });
});

describe("computeCostUsd", () => {
  it("returns null when rate is unknown", () => {
    expect(
      computeCostUsd("openai", "gpt-?", { input: 100, output: 100 }),
    ).toBeNull();
  });

  it("computes cost from token counts (per-Mtok rates)", () => {
    const cost = computeCostUsd("anthropic", "claude-opus-4-7", {
      input: 1_000_000,
      output: 1_000_000,
    });
    expect(cost).toBeCloseTo(30, 6); // 5 + 25
  });

  it("computes small fractional costs accurately", () => {
    const cost = computeCostUsd("anthropic", "claude-haiku-4-5", {
      input: 100,
      output: 200,
    });
    // (100 / 1e6) * 1 + (200 / 1e6) * 5 = 1.1e-3
    expect(cost).toBeCloseTo(0.0011, 8);
  });
});
