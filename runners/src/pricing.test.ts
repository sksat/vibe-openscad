import { describe, expect, it } from "vitest";
import { computeCostUsd, getRate } from "./pricing.js";

/**
 * 価格の **値そのもの** は models.yml(モデルカタログ)側にあり、
 * 「bench-config の全モデルが価格を持つか」は models.test.ts の網羅テストが
 * 見る。ここで固定するのは **解決規則** — どのエントリに解決されるべきか、
 * と USD の計算式。個々のモデルの $ をここに二重に書かない(書くと
 * モデル追加のたびにテストを書き足す羽目になる)。
 */
describe("getRate", () => {
  it("resolves a known model to a positive rate", () => {
    const rate = getRate("anthropic", "claude-opus-4-7");
    expect(rate).not.toBeNull();
    expect(rate!.inputPerMtok).toBeGreaterThan(0);
    expect(rate!.outputPerMtok).toBeGreaterThan(rate!.inputPerMtok);
  });

  it("lets a dated snapshot inherit its alias rate", () => {
    // 将来 opus-4-7 に dated snapshot が付いても alias の価格で計算される。
    expect(getRate("anthropic", "claude-opus-4-7-20260601")).toEqual(
      getRate("anthropic", "claude-opus-4-7"),
    );
    expect(getRate("anthropic", "claude-haiku-4-5-20251001")).toEqual(
      getRate("anthropic", "claude-haiku-4-5"),
    );
    expect(getRate("openai", "gpt-5.4-2026-03-05")).toEqual(
      getRate("openai", "gpt-5.4"),
    );
  });

  it("uses the more specific family rate, not the base family", () => {
    // regression: gpt-5.4-mini が gpt-5 の prefix に落ちて誤った価格になった。
    expect(getRate("openai", "gpt-5.4-mini-2026-03-17")).not.toEqual(
      getRate("openai", "gpt-5.4-2026-03-05"),
    );
    expect(getRate("openai", "gpt-5.4-mini-2026-03-17")).not.toEqual(
      getRate("openai", "gpt-5"),
    );
    // catch-all の `claude-opus-4-`(旧世代)に落ちないこと。
    expect(getRate("anthropic", "claude-opus-4-8")).not.toEqual(
      getRate("anthropic", "claude-opus-4-20250514"),
    );
  });

  it("returns null for unknown providers/models", () => {
    expect(getRate("anthropic", "definitely-not-a-model")).toBeNull();
    expect(getRate("nonsuch-provider", "anything")).toBeNull();
    expect(getRate("openai", "wat-is-this")).toBeNull();
  });

  it("does not cross provider boundaries", () => {
    expect(getRate("openai", "claude-opus-4-7")).toBeNull();
    expect(getRate("anthropic", "gpt-5")).toBeNull();
  });

  it("returns null for self-hosted models (no billing)", () => {
    expect(getRate("openai-self-hosted", "openai/gpt-oss-20b")).toBeNull();
    expect(getRate("openai-self-hosted", "qwen3-8b")).toBeNull();
  });
});

describe("computeCostUsd", () => {
  it("returns null when rate is unknown", () => {
    expect(
      computeCostUsd("openai", "gpt-?", { input: 100, output: 100 }),
    ).toBeNull();
  });

  it("computes cost from token counts (per-Mtok rates)", () => {
    const rate = getRate("anthropic", "claude-opus-4-7")!;
    const cost = computeCostUsd("anthropic", "claude-opus-4-7", {
      input: 1_000_000,
      output: 1_000_000,
    });
    expect(cost).toBeCloseTo(rate.inputPerMtok + rate.outputPerMtok, 10);
  });

  it("scales linearly with token counts", () => {
    const one = computeCostUsd("anthropic", "claude-opus-4-7", {
      input: 1000,
      output: 500,
    })!;
    const ten = computeCostUsd("anthropic", "claude-opus-4-7", {
      input: 10_000,
      output: 5_000,
    })!;
    expect(ten).toBeCloseTo(one * 10, 10);
  });

  it("is zero for zero tokens", () => {
    expect(
      computeCostUsd("anthropic", "claude-opus-4-7", { input: 0, output: 0 }),
    ).toBe(0);
  });
});
