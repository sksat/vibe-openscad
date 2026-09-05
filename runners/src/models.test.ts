import { describe, expect, it } from "vitest";
import { loadBenchConfig } from "./matrix.js";
import {
  loadModelRegistry,
  modelRegistry,
  parseModelRegistry,
  repoRootFrom,
  resolveModel,
  resolveModelIn,
} from "./models.js";

/** Minimal hand-written registry for the resolution-logic tests. */
const REGISTRY = parseModelRegistry({
  "claude-opus-4-": {
    provider: "anthropic",
    rate: { in: 15, out: 75 },
    vision: true,
    effort: null,
    thinking: "off",
  },
  "claude-opus-4-5": {
    provider: "anthropic",
    rate: { in: 5, out: 25 },
    effort: "high",
  },
  "gpt-5": {
    provider: "openai",
    rate: { in: 1.25, out: 10 },
    vision: true,
    effort: "medium",
  },
  "gpt-5.4": { provider: "openai", rate: { in: 2, out: 16 } },
  "gpt-5.4-mini": { provider: "openai", rate: { in: 0.4, out: 3 } },
});

describe("resolveModelIn", () => {
  it("resolves an exact id", () => {
    expect(resolveModelIn(REGISTRY, "gpt-5")?.rate).toEqual({
      in: 1.25,
      out: 10,
    });
  });

  it("returns null for an id no prefix matches", () => {
    expect(resolveModelIn(REGISTRY, "definitely-not-a-model")).toBeNull();
  });

  it("lets a dated snapshot inherit its alias entry", () => {
    expect(resolveModelIn(REGISTRY, "gpt-5.4-2026-03-05")?.rate).toEqual({
      in: 2,
      out: 16,
    });
  });

  it("merges per field, longest prefix winning", () => {
    // rate/effort come from `claude-opus-4-5`, vision/thinking are inherited
    // from the shorter `claude-opus-4-` catch-all.
    const m = resolveModelIn(REGISTRY, "claude-opus-4-5-20251101");
    expect(m).toMatchObject({
      provider: "anthropic",
      rate: { in: 5, out: 25 },
      effort: "high",
      vision: true,
      thinking: "off",
    });
  });

  it("keeps the longest match when several prefixes overlap", () => {
    expect(resolveModelIn(REGISTRY, "gpt-5.4-mini-2026-03-17")?.rate).toEqual({
      in: 0.4,
      out: 3,
    });
  });

  it("preserves an explicit null (declared 'no knob') over inheritance", () => {
    expect(resolveModelIn(REGISTRY, "claude-opus-4-20250514")?.effort).toBeNull();
  });

  it("filters by provider when one is given", () => {
    expect(resolveModelIn(REGISTRY, "gpt-5", "openai")?.rate).toEqual({
      in: 1.25,
      out: 10,
    });
    expect(resolveModelIn(REGISTRY, "gpt-5", "anthropic")).toBeNull();
  });
});

describe("line / snapshot", () => {
  it("treats snapshots of one model line as separate models", () => {
    const reg = parseModelRegistry({
      "gemini-x-lite": {
        provider: "google",
        rate: { in: 1, out: 2 },
        line: "gemini-x-lite",
        snapshot: "05-2026",
      },
      "gemini-x-lite-preview": {
        provider: "google",
        rate: { in: 3, out: 4 },
        snapshot: "preview-03-2026",
      },
    });
    const ga = resolveModelIn(reg, "gemini-x-lite");
    const preview = resolveModelIn(reg, "gemini-x-lite-preview");
    // 別モデルとして解決される
    expect(ga?.rate).toEqual({ in: 1, out: 2 });
    expect(preview?.rate).toEqual({ in: 3, out: 4 });
    // line は短い prefix から継承されるので、両者が同じモデルだと分かる
    expect(preview?.line).toBe("gemini-x-lite");
    expect(ga?.line).toBe("gemini-x-lite");
    // snapshot は各エントリが自分で名乗る
    expect(ga?.snapshot).toBe("05-2026");
    expect(preview?.snapshot).toBe("preview-03-2026");
  });

  it("lets a dated snapshot inherit its alias line", () => {
    const reg = parseModelRegistry({
      "claude-opus-9-9": {
        provider: "anthropic",
        rate: { in: 1, out: 2 },
        line: "claude-opus-9-9",
      },
    });
    expect(resolveModelIn(reg, "claude-opus-9-9-20260101")?.line).toBe(
      "claude-opus-9-9",
    );
  });
});

describe("parseModelRegistry", () => {
  it("rejects an unknown effort level", () => {
    expect(() =>
      parseModelRegistry({ foo: { provider: "openai", effort: "turbo" } }),
    ).toThrow(/effort/);
  });

  it("rejects an unknown field (typo guard)", () => {
    expect(() =>
      parseModelRegistry({ foo: { provider: "openai", visoin: true } }),
    ).toThrow();
  });

  it("requires a provider", () => {
    expect(() => parseModelRegistry({ foo: { vision: true } })).toThrow(
      /provider/,
    );
  });
});

describe("models.yml", () => {
  const root = repoRootFrom(process.cwd());
  const registry = modelRegistry();

  it("parses", () => {
    expect(Object.keys(registry).length).toBeGreaterThan(10);
  });

  it("is loadable from an explicit path", () => {
    expect(loadModelRegistry(`${root}/models.yml`)).toEqual(registry);
  });

  // これがモデル追加時の網羅ガード: bench-config.yml に載っている
  // (provider, model) がカタログで説明されていなければ落ちる。モデルを
  // 足すたびに手書きテストを増やす必要が無くなる代わりに、models.yml へ
  // エントリを足すことが必須になる。
  describe("covers every model in bench-config.yml", () => {
    const cfg = loadBenchConfig(`${root}/bench-config.yml`);
    const pairs = new Map<string, { provider: string; model: string }>();
    for (const entry of cfg.matrix) {
      if (!("model" in entry)) continue;
      pairs.set(`${entry.provider}::${entry.model}`, {
        provider: entry.provider,
        model: entry.model,
      });
    }

    it("has at least one bare entry to check", () => {
      expect(pairs.size).toBeGreaterThan(0);
    });

    it("gives every entry in a shared line a distinct snapshot", () => {
      const byLine = new Map<string, { id: string; snapshot?: string }[]>();
      for (const [id, entry] of Object.entries(registry)) {
        if (!entry.line) continue;
        const list = byLine.get(entry.line) ?? [];
        list.push({ id, ...(entry.snapshot ? { snapshot: entry.snapshot } : {}) });
        byLine.set(entry.line, list);
      }
      for (const [line, members] of byLine) {
        if (members.length < 2) continue;
        const snapshots = members.map((m) => m.snapshot);
        expect(
          snapshots.every((v) => v !== undefined),
          `line ${line}: 同じ line に複数あるなら全員 snapshot が要る`,
        ).toBe(true);
        expect(
          new Set(snapshots).size,
          `line ${line}: snapshot が重複している`,
        ).toBe(members.length);
      }
    });

    for (const [key, { provider, model }] of pairs) {
      it(`describes ${key}`, () => {
        const spec = resolveModel(model, provider);
        expect(spec, `no models.yml entry matches ${key}`).not.toBeNull();
        expect(
          typeof spec!.vision,
          `${key}: declare \`vision\` in models.yml`,
        ).toBe("boolean");
        // セルフホストは課金が無いので rate を持たない。
        if (!provider.endsWith("-self-hosted")) {
          expect(spec!.rate, `${key}: declare \`rate\` in models.yml`)
            .toBeDefined();
        }
        // effort / thinking は「軸が無い」ことを null で明示させる。
        if (provider === "anthropic") {
          expect("effort" in spec!, `${key}: declare \`effort\``).toBe(true);
          expect("thinking" in spec!, `${key}: declare \`thinking\``).toBe(
            true,
          );
        }
        if (provider === "openai") {
          expect("effort" in spec!, `${key}: declare \`effort\``).toBe(true);
        }
        if (provider === "google") {
          expect("thinking" in spec!, `${key}: declare \`thinking\``).toBe(
            true,
          );
        }
      });
    }
  });
});
