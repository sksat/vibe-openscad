import { loadBenchConfig } from "@vibe-openscad/runners/src/matrix.js";
import { repoRootFrom } from "@vibe-openscad/runners/src/models.js";
import { describe, expect, it } from "vitest";
import { modelSortKey, parseModelLabel } from "./dataset.js";

/**
 * bench-config.yml に載っている全モデルが UI 側でも「知られている」ことを
 * 保証する網羅テスト。命名規則から外れる id(例: `gpt-5.6-sol`)を matrix に
 * 足すと、ラベルが素の id のまま出たりソートが末尾に落ちたりするが、
 * それをモデル追加のたびに手書きテストで気付く運用にはしたくない。
 *
 * 落ちたときの直し方は 2 つ:
 *   - id が既存の命名規則に乗るなら dataset.ts のパターンを直す
 *   - 乗らない個体なら models.yml にその模型の `label:` / `sort:` を宣言する
 */
describe("bench-config models are renderable", () => {
  const root = repoRootFrom(process.cwd());
  const cfg = loadBenchConfig(`${root}/bench-config.yml`);
  const pairs = new Map<string, { provider: string; model: string }>();
  for (const entry of cfg.matrix) {
    if (!("model" in entry)) continue;
    pairs.set(`${entry.provider}::${entry.model}`, {
      provider: entry.provider,
      model: entry.model,
    });
  }

  it("has at least one model to check", () => {
    expect(pairs.size).toBeGreaterThan(0);
  });

  for (const [key, { provider, model }] of pairs) {
    it(`renders a model badge for ${key}`, () => {
      const badges = parseModelLabel(model);
      expect(
        badges.some((b) => b.kind === "model"),
        `${key}: falls through to a plain "other" badge`,
      ).toBe(true);
    });

    // セルフホストは意図的に末尾の辞書順バケツ([99, ...])に置いている。
    if (!provider.endsWith("-self-hosted")) {
      it(`ranks ${key} in a known family bucket`, () => {
        expect(
          modelSortKey(model)[0],
          `${key}: unranked — teach dataset.ts the pattern or add sort: to models.yml`,
        ).not.toBe(99);
      });
    }
  }
});
