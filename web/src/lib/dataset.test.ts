import { describe, expect, it } from "vitest";
import type { RunMeta } from "@vibe-openscad/runners/src/schema.js";
import {
  buildTaskSlugMap,
  compareModelsByRank,
  effortInfoFor,
  formatCost,
  isSelfHostedProvider,
  parseMatrixId,
  providerDisplayLabel,
  providerVendor,
  runBadges,
  runGroupProvider,
  shortModelLabel,
  taskSlug,
  thinkingInfoFor,
} from "./dataset.js";

function fakeMeta(overrides: Partial<RunMeta>): RunMeta {
  return {
    runId: "r",
    taskId: "t",
    matrixId: "bare/claude-opus-4-5",
    signature: "a".repeat(64),
    fingerprint: {
      schemaVersion: 1,
      taskHash: "b".repeat(64),
      harness: { kind: "bare", provider: "anthropic", model: "claude-opus-4-5-20251101" },
      openscadVersion: "OpenSCAD",
      promptTemplateHash: "c".repeat(64),
    },
    provider: "anthropic",
    model: "claude-opus-4-5-20251101",
    harness: { kind: "bare" },
    status: "success",
    timing: { totalMs: 100 },
    createdAt: "2026-04-27T00:00:00Z",
    ...overrides,
  };
}

describe("parseMatrixId", () => {
  it("splits a bare claude alias entry into harness + vendor + model", () => {
    expect(parseMatrixId("bare/claude-opus-4-7")).toEqual([
      { kind: "harness", label: "bare" },
      { kind: "vendor", label: "claude", vendor: "claude" },
      {
        kind: "model",
        label: "opus 4.7",
        title: "claude-opus-4-7",
        vendor: "claude",
      },
    ]);
  });

  it("parses Fable (major-only version, no minor) into vendor + model", () => {
    expect(parseMatrixId("bare/claude-fable-5")).toEqual([
      { kind: "harness", label: "bare" },
      { kind: "vendor", label: "claude", vendor: "claude" },
      {
        kind: "model",
        label: "fable 5",
        title: "claude-fable-5",
        vendor: "claude",
      },
    ]);
  });

  it("merges the snapshot date into the model badge label", () => {
    expect(parseMatrixId("bare/claude-haiku-4-5-20251001")).toEqual([
      { kind: "harness", label: "bare" },
      { kind: "vendor", label: "claude", vendor: "claude" },
      {
        kind: "model",
        label: "haiku 4.5 2025-10-01",
        title: "claude-haiku-4-5-20251001",
        vendor: "claude" as const,
      },
    ]);
  });

  it("treats multi-segment bare variants (bare-think-off / bare-think-adaptive) as harness", () => {
    expect(parseMatrixId("bare-think-adaptive/claude-fable-5")[0]).toEqual({
      kind: "harness",
      label: "bare-think-adaptive",
    });
    expect(parseMatrixId("bare-think-off/claude-opus-4-7")[0]).toEqual({
      kind: "harness",
      label: "bare-think-off",
    });
  });

  it("recognizes external-agent as a harness", () => {
    expect(parseMatrixId("external-agent/claude-code")[0]).toEqual({
      kind: "harness",
      label: "external-agent",
    });
  });

  it("falls back to 'other' for unknown segments", () => {
    expect(parseMatrixId("custom/something")).toEqual([
      { kind: "other", label: "custom" },
      { kind: "other", label: "something" },
    ]);
  });

  it("handles a model id without a leading harness prefix", () => {
    expect(parseMatrixId("claude-sonnet-4-5-20250929")).toEqual([
      { kind: "vendor", label: "claude", vendor: "claude" },
      {
        kind: "model",
        label: "sonnet 4.5 2025-09-29",
        title: "claude-sonnet-4-5-20250929",
        vendor: "claude",
      },
    ]);
  });
});

describe("runBadges", () => {
  it("uses meta.model so the date suffix shows even when matrixId omits it", () => {
    const m = fakeMeta({
      matrixId: "bare/claude-opus-4-5",
      model: "claude-opus-4-5-20251101",
    });
    expect(runBadges(m)).toEqual([
      { kind: "vendor", label: "claude", vendor: "claude" },
      {
        kind: "model",
        label: "opus 4.5 2025-11-01",
        title: "claude-opus-4-5-20251101",
        vendor: "claude",
      },
      { kind: "harness", label: "bare" },
    ]);
  });

  it("falls back to harness.kind when matrixId prefix is unrecognized", () => {
    const m = fakeMeta({
      matrixId: "weirdthing/claude-opus-4-7",
      model: "claude-opus-4-7",
    });
    // harness is now last
    const segs = runBadges(m);
    expect(segs[segs.length - 1]).toEqual({ kind: "harness", label: "bare" });
  });

  it("handles a major-only dated id like claude-opus-4-20250514 (no minor)", () => {
    const m = fakeMeta({
      matrixId: "bare/claude-opus-4-0",
      model: "claude-opus-4-20250514",
    });
    const segs = runBadges(m);
    expect(segs).toContainEqual({
      kind: "model",
      label: "opus 4 2025-05-14",
      title: "claude-opus-4-20250514",
      vendor: "claude",
    });
  });

  it("recognizes Gemini model ids", () => {
    const m = fakeMeta({
      matrixId: "bare/gemini-2.5-flash",
      model: "gemini-2.5-flash",
      provider: "google",
    });
    expect(runBadges(m)).toEqual([
      { kind: "vendor", label: "gemini", vendor: "gemini" },
      {
        kind: "model",
        label: "flash 2.5",
        title: "gemini-2.5-flash",
        vendor: "gemini",
      },
      { kind: "harness", label: "bare" },
    ]);
  });

  it("recognizes Gemini 3 preview models (with -preview suffix)", () => {
    const m = fakeMeta({
      matrixId: "bare/gemini-3.1-pro-preview",
      model: "gemini-3.1-pro-preview",
      provider: "google",
    });
    expect(runBadges(m)).toEqual([
      { kind: "vendor", label: "gemini", vendor: "gemini" },
      {
        kind: "model",
        label: "pro 3.1 preview",
        title: "gemini-3.1-pro-preview",
        vendor: "gemini",
      },
      { kind: "harness", label: "bare" },
    ]);
  });

  it("recognizes Gemini 3 flash without minor version (gemini-3-flash-preview)", () => {
    const m = fakeMeta({
      matrixId: "bare/gemini-3-flash-preview",
      model: "gemini-3-flash-preview",
      provider: "google",
    });
    const segs = runBadges(m);
    expect(segs).toContainEqual({
      kind: "model",
      label: "flash 3 preview",
      title: "gemini-3-flash-preview",
      vendor: "gemini",
    });
  });

  it("recognizes flash-lite (hyphenated variant)", () => {
    const m = fakeMeta({
      matrixId: "bare/gemini-2.5-flash-lite",
      model: "gemini-2.5-flash-lite",
      provider: "google",
    });
    expect(runBadges(m)).toEqual([
      { kind: "vendor", label: "gemini", vendor: "gemini" },
      {
        kind: "model",
        label: "flash-lite 2.5",
        title: "gemini-2.5-flash-lite",
        vendor: "gemini",
      },
      { kind: "harness", label: "bare" },
    ]);
  });

  it("recognizes OpenAI GPT models", () => {
    const m = fakeMeta({
      matrixId: "bare/gpt-5",
      model: "gpt-5",
      provider: "openai",
    });
    expect(runBadges(m)).toEqual([
      { kind: "vendor", label: "openai", vendor: "openai" },
      { kind: "model", label: "gpt 5", title: "gpt-5", vendor: "openai" },
      { kind: "harness", label: "bare" },
    ]);
  });

  it("recognizes gpt-5-mini and gpt-5-nano", () => {
    expect(
      runBadges(fakeMeta({ matrixId: "bare/gpt-5-mini", model: "gpt-5-mini", provider: "openai" }))
        .find((s) => s.kind === "model")?.label,
    ).toBe("gpt 5 mini");
    expect(
      runBadges(fakeMeta({ matrixId: "bare/gpt-5-nano", model: "gpt-5-nano", provider: "openai" }))
        .find((s) => s.kind === "model")?.label,
    ).toBe("gpt 5 nano");
  });

  it("recognizes OpenAI o-series reasoning models", () => {
    expect(
      runBadges(fakeMeta({ matrixId: "bare/o3", model: "o3", provider: "openai" }))
        .find((s) => s.kind === "model")?.label,
    ).toBe("o3");
    expect(
      runBadges(fakeMeta({ matrixId: "bare/o4-mini", model: "o4-mini", provider: "openai" }))
        .find((s) => s.kind === "model")?.label,
    ).toBe("o4 mini");
  });

  it("emits an `other` model badge for unrecognized model ids", () => {
    const m = fakeMeta({
      matrixId: "bare/something",
      model: "totally-custom-model",
      provider: "custom",
    });
    const segs = runBadges(m);
    expect(segs).toContainEqual({
      kind: "other",
      label: "totally-custom-model",
    });
  });
});

describe("formatCost", () => {
  it("formats null/undefined as —", () => {
    expect(formatCost(null)).toBe("—");
    expect(formatCost(undefined)).toBe("—");
  });

  it("returns $0 for exactly zero", () => {
    expect(formatCost(0)).toBe("$0");
  });

  it("returns <$0.0001 for tiny non-zero values", () => {
    expect(formatCost(0.00001)).toBe("<$0.0001");
  });

  it("uses 4 decimals under one dollar", () => {
    expect(formatCost(0.0123)).toBe("$0.0123");
  });

  it("uses 2 decimals for values >= 1", () => {
    expect(formatCost(1.234)).toBe("$1.23");
    expect(formatCost(12.345)).toBe("$12.35");
  });
});

describe("effortInfoFor", () => {
  function makeBare(over: {
    provider: string;
    model: string;
    matrixId?: string;
    modelOptions?: Record<string, unknown>;
  }): RunMeta {
    return fakeMeta({
      provider: over.provider as RunMeta["provider"],
      model: over.model,
      matrixId: over.matrixId ?? `bare/${over.model}`,
      fingerprint: {
        schemaVersion: 1,
        taskHash: "b".repeat(64),
        harness: {
          kind: "bare",
          provider: over.provider,
          model: over.model,
          ...(over.modelOptions ? { modelOptions: over.modelOptions } : {}),
        },
        openscadVersion: "OpenSCAD",
        promptTemplateHash: "c".repeat(64),
      },
    });
  }

  it("returns { high, isDefault: true } for default bare on Opus 4.7", () => {
    expect(
      effortInfoFor(
        makeBare({ provider: "anthropic", model: "claude-opus-4-7" }),
      ),
    ).toEqual({ value: "high", isDefault: true });
  });

  it("returns { high, isDefault: true } for default bare on Fable 5", () => {
    expect(
      effortInfoFor(
        makeBare({ provider: "anthropic", model: "claude-fable-5" }),
      ),
    ).toEqual({ value: "high", isDefault: true });
  });

  it("returns explicit value for bare-low on Opus 4.7", () => {
    expect(
      effortInfoFor(
        makeBare({
          provider: "anthropic",
          model: "claude-opus-4-7",
          matrixId: "bare-low/claude-opus-4-7",
          modelOptions: { output_config: { effort: "low" } },
        }),
      ),
    ).toEqual({ value: "low", isDefault: false });
  });

  it("returns { medium, isDefault: true } for default gpt-5", () => {
    expect(
      effortInfoFor(
        makeBare({ provider: "openai", model: "gpt-5-2025-08-07" }),
      ),
    ).toEqual({ value: "medium", isDefault: true });
  });

  it("returns medium default for gpt-5.5 and codex variants", () => {
    expect(
      effortInfoFor(
        makeBare({ provider: "openai", model: "gpt-5.5-2026-04-23" }),
      ),
    ).toEqual({ value: "medium", isDefault: true });
    expect(
      effortInfoFor(
        makeBare({ provider: "openai", model: "gpt-5-codex" }),
      ),
    ).toEqual({ value: "medium", isDefault: true });
    expect(
      effortInfoFor(
        makeBare({ provider: "openai", model: "gpt-5.1-codex" }),
      ),
    ).toEqual({ value: "medium", isDefault: true });
    expect(
      effortInfoFor(
        makeBare({ provider: "openai", model: "gpt-5.1-codex-max" }),
      ),
    ).toEqual({ value: "medium", isDefault: true });
  });

  it("returns explicit value for OpenAI reasoning override", () => {
    expect(
      effortInfoFor(
        makeBare({
          provider: "openai",
          model: "gpt-5.4-2026-03-05",
          matrixId: "bare-high/gpt-5.4",
          modelOptions: { reasoning: { effort: "high" } },
        }),
      ),
    ).toEqual({ value: "high", isDefault: false });
  });

  it("returns null for models without effort support (sonnet 4.5, haiku 4.5, gpt-4.1)", () => {
    expect(
      effortInfoFor(
        makeBare({
          provider: "anthropic",
          model: "claude-haiku-4-5-20251001",
        }),
      ),
    ).toBeNull();
    expect(
      effortInfoFor(
        makeBare({
          provider: "anthropic",
          model: "claude-sonnet-4-5-20250929",
        }),
      ),
    ).toBeNull();
    expect(
      effortInfoFor(
        makeBare({
          provider: "openai",
          model: "gpt-4.1-2025-04-14",
        }),
      ),
    ).toBeNull();
  });

  it("returns Sonnet 4.6 default = high", () => {
    expect(
      effortInfoFor(
        makeBare({ provider: "anthropic", model: "claude-sonnet-4-6" }),
      ),
    ).toEqual({ value: "high", isDefault: true });
  });

  it("returns null for Gemini (effort not modeled here yet)", () => {
    expect(
      effortInfoFor(
        makeBare({ provider: "google", model: "gemini-3.1-pro-preview" }),
      ),
    ).toBeNull();
  });
});

describe("thinkingInfoFor", () => {
  function makeBare(over: {
    provider: string;
    model: string;
    matrixId?: string;
    modelOptions?: Record<string, unknown>;
  }): RunMeta {
    return fakeMeta({
      provider: over.provider as RunMeta["provider"],
      model: over.model,
      matrixId: over.matrixId ?? `bare/${over.model}`,
      fingerprint: {
        schemaVersion: 1,
        taskHash: "b".repeat(64),
        harness: {
          kind: "bare",
          provider: over.provider,
          model: over.model,
          ...(over.modelOptions ? { modelOptions: over.modelOptions } : {}),
        },
        openscadVersion: "OpenSCAD",
        promptTemplateHash: "c".repeat(64),
      },
    });
  }

  it("returns adaptive default for Opus 4.7", () => {
    expect(
      thinkingInfoFor(
        makeBare({ provider: "anthropic", model: "claude-opus-4-7" }),
      ),
    ).toEqual({ value: "adaptive", isDefault: true });
  });

  it("returns adaptive default for Sonnet 4.6", () => {
    expect(
      thinkingInfoFor(
        makeBare({ provider: "anthropic", model: "claude-sonnet-4-6" }),
      ),
    ).toEqual({ value: "adaptive", isDefault: true });
  });

  it("returns adaptive default for Fable 5 (always-on thinking; cannot be disabled)", () => {
    expect(
      thinkingInfoFor(
        makeBare({ provider: "anthropic", model: "claude-fable-5" }),
      ),
    ).toEqual({ value: "adaptive", isDefault: true });
  });

  it("returns adaptive (explicit) for Fable 5 think-adaptive variant", () => {
    expect(
      thinkingInfoFor(
        makeBare({
          provider: "anthropic",
          model: "claude-fable-5",
          matrixId: "bare-think-adaptive/claude-fable-5",
          modelOptions: { thinking: { type: "adaptive" } },
        }),
      ),
    ).toEqual({ value: "adaptive", isDefault: false });
  });

  it("returns 'off' when thinking explicitly disabled", () => {
    expect(
      thinkingInfoFor(
        makeBare({
          provider: "anthropic",
          model: "claude-opus-4-7",
          modelOptions: { thinking: { type: "disabled" } },
        }),
      ),
    ).toEqual({ value: "off", isDefault: false });
  });

  it("returns adaptive (explicit) when thinking explicitly adaptive", () => {
    expect(
      thinkingInfoFor(
        makeBare({
          provider: "anthropic",
          model: "claude-opus-4-7",
          modelOptions: { thinking: { type: "adaptive" } },
        }),
      ),
    ).toEqual({ value: "adaptive", isDefault: false });
  });

  it("returns enabled-<N> when thinking explicitly enabled with budget", () => {
    expect(
      thinkingInfoFor(
        makeBare({
          provider: "anthropic",
          model: "claude-opus-4-6",
          modelOptions: {
            thinking: { type: "enabled", budget_tokens: 4096 },
          },
        }),
      ),
    ).toEqual({ value: "enabled-4096", isDefault: false });
  });

  it("returns 'off' default for older Anthropic without adaptive support", () => {
    // Sonnet 4.5 / Haiku 4.5 / Opus 4.5: no adaptive default; thinking is off
    // unless explicitly enabled.
    expect(
      thinkingInfoFor(
        makeBare({
          provider: "anthropic",
          model: "claude-sonnet-4-5-20250929",
        }),
      ),
    ).toEqual({ value: "off", isDefault: true });
    expect(
      thinkingInfoFor(
        makeBare({
          provider: "anthropic",
          model: "claude-haiku-4-5-20251001",
        }),
      ),
    ).toEqual({ value: "off", isDefault: true });
  });

  it("returns null for OpenAI (thinking subsumed by effort axis)", () => {
    expect(
      thinkingInfoFor(
        makeBare({ provider: "openai", model: "gpt-5-2025-08-07" }),
      ),
    ).toBeNull();
  });

  it("returns dynamic default for Gemini 3.x / 2.5 models", () => {
    expect(
      thinkingInfoFor(
        makeBare({ provider: "google", model: "gemini-3.1-pro-preview" }),
      ),
    ).toEqual({ value: "dynamic", isDefault: true });
    expect(
      thinkingInfoFor(
        makeBare({ provider: "google", model: "gemini-2.5-flash" }),
      ),
    ).toEqual({ value: "dynamic", isDefault: true });
  });

  it("returns 'off' when Gemini thinkingBudget=0", () => {
    expect(
      thinkingInfoFor(
        makeBare({
          provider: "google",
          model: "gemini-3.1-pro-preview",
          modelOptions: {
            config: { thinkingConfig: { thinkingBudget: 0 } },
          },
        }),
      ),
    ).toEqual({ value: "off", isDefault: false });
  });

  it("returns budget-<N> when Gemini thinkingBudget is a positive number", () => {
    expect(
      thinkingInfoFor(
        makeBare({
          provider: "google",
          model: "gemini-2.5-pro",
          modelOptions: {
            config: { thinkingConfig: { thinkingBudget: 4096 } },
          },
        }),
      ),
    ).toEqual({ value: "budget-4096", isDefault: false });
  });

  it("returns dynamic (explicit) when Gemini thinkingBudget=-1", () => {
    expect(
      thinkingInfoFor(
        makeBare({
          provider: "google",
          model: "gemini-2.5-pro",
          modelOptions: {
            config: { thinkingConfig: { thinkingBudget: -1 } },
          },
        }),
      ),
    ).toEqual({ value: "dynamic", isDefault: false });
  });
});

describe("shortModelLabel", () => {
  it("formats Claude model with vendor + version (drops date)", () => {
    expect(shortModelLabel("claude-opus-4-7")).toBe("claude opus 4.7");
    expect(shortModelLabel("claude-fable-5")).toBe("claude fable 5");
    expect(shortModelLabel("claude-haiku-4-5-20251001")).toBe("claude haiku 4.5");
    expect(shortModelLabel("claude-sonnet-4-6")).toBe("claude sonnet 4.6");
  });

  it("formats GPT family (drops date suffix)", () => {
    expect(shortModelLabel("gpt-5.4-2026-03-05")).toBe("gpt 5.4");
    expect(shortModelLabel("gpt-5.4-mini-2026-03-17")).toBe("gpt 5.4 mini");
    expect(shortModelLabel("gpt-5-2025-08-07")).toBe("gpt 5");
    expect(shortModelLabel("gpt-4.1-2025-04-14")).toBe("gpt 4.1");
  });

  it("formats GPT codex variants", () => {
    expect(shortModelLabel("gpt-5-codex")).toBe("gpt 5 codex");
    expect(shortModelLabel("gpt-5.1-codex")).toBe("gpt 5.1 codex");
    expect(shortModelLabel("gpt-5.1-codex-max")).toBe("gpt 5.1 codex max");
  });

  it("formats o-series reasoning models", () => {
    expect(shortModelLabel("o3-2025-04-16")).toBe("o3");
    expect(shortModelLabel("o4-mini-2025-04-16")).toBe("o4 mini");
  });

  it("formats Gemini (drops 'preview' suffix)", () => {
    expect(shortModelLabel("gemini-3.1-pro-preview")).toBe("gemini 3.1 pro");
    expect(shortModelLabel("gemini-2.5-flash-lite")).toBe("gemini 2.5 flash-lite");
    expect(shortModelLabel("gemini-3-flash-preview")).toBe("gemini 3 flash");
  });

  it("falls back to the input string for unknown shapes", () => {
    expect(shortModelLabel("local-llama-7b")).toBe("local-llama-7b");
  });
});

describe("taskSlug", () => {
  it("strips tier-N- prefix from id when slug is unspecified", () => {
    expect(taskSlug({ id: "tier-1-mug" })).toBe("mug");
    expect(taskSlug({ id: "tier-2-hex-bolt" })).toBe("hex-bolt");
    expect(taskSlug({ id: "tier-3-butt-hinge" })).toBe("butt-hinge");
  });

  it("returns the explicit slug when provided", () => {
    // id 自体は signature fingerprint に効くので変えたくないが、URL は
    // 具体的な名前にしたい(`mug` だけだと曖昧、`simple-mug` にしたい)
    // ケースで slug を明示する。
    expect(taskSlug({ id: "tier-1-mug", slug: "simple-mug" })).toBe("simple-mug");
  });

  it("falls back to id when neither slug nor tier-prefix matches", () => {
    expect(taskSlug({ id: "custom-task" })).toBe("custom-task");
  });
});

describe("buildTaskSlugMap", () => {
  it("maps each task id to its slug", () => {
    const m = buildTaskSlugMap([
      { id: "tier-1-mug", slug: "simple-mug" },
      { id: "tier-2-offset-handle-mug" },
      { id: "tier-3-butt-hinge" },
    ]);
    expect(m.get("tier-1-mug")).toBe("simple-mug");
    expect(m.get("tier-2-offset-handle-mug")).toBe("offset-handle-mug");
    expect(m.get("tier-3-butt-hinge")).toBe("butt-hinge");
  });

  it("throws when two tasks would collide on the same slug", () => {
    // tier-1-mug と tier-2-mug が両方 slug 未指定だと両方 `mug` になる。
    // どちらかに explicit slug を付けないと一意な URL を作れないので
    // ビルド時に弾く。
    expect(() =>
      buildTaskSlugMap([
        { id: "tier-1-mug" },
        { id: "tier-2-mug" },
      ]),
    ).toThrow(/slug "mug" maps to multiple task ids/);
  });
});

describe("compareModelsByRank", () => {
  function sorted(models: string[]): string[] {
    return [...models].sort(compareModelsByRank);
  }

  it("sorts Claude models fable > opus > sonnet > haiku, then newest version first", () => {
    expect(
      sorted([
        "claude-haiku-4-5-20251001",
        "claude-sonnet-4-6",
        "claude-opus-4-5-20251101",
        "claude-fable-5",
        "claude-opus-4-7",
        "claude-sonnet-4-5-20250929",
      ]),
    ).toEqual([
      "claude-fable-5",
      "claude-opus-4-7",
      "claude-opus-4-5-20251101",
      "claude-sonnet-4-6",
      "claude-sonnet-4-5-20250929",
      "claude-haiku-4-5-20251001",
    ]);
  });

  it("sorts Gemini models pro > flash > flash-lite, newer version first", () => {
    expect(
      sorted([
        "gemini-2.5-flash-lite",
        "gemini-3.1-flash-lite-preview",
        "gemini-3.1-pro-preview",
        "gemini-3-flash-preview",
        "gemini-2.5-pro",
        "gemini-2.5-flash",
      ]),
    ).toEqual([
      "gemini-3.1-pro-preview",
      "gemini-2.5-pro",
      "gemini-3-flash-preview",
      "gemini-2.5-flash",
      "gemini-3.1-flash-lite-preview",
      "gemini-2.5-flash-lite",
    ]);
  });

  it("sorts OpenAI gpt-* by version desc, with mini/nano after the base", () => {
    expect(
      sorted([
        "gpt-5-nano-2025-08-07",
        "gpt-5.4-mini-2026-03-17",
        "gpt-5",
        "gpt-5.5-2026-04-23",
        "gpt-5.4-2026-03-05",
        "gpt-4.1-2025-04-14",
      ]),
    ).toEqual([
      "gpt-5.5-2026-04-23",
      "gpt-5.4-2026-03-05",
      "gpt-5.4-mini-2026-03-17",
      "gpt-5",
      "gpt-5-nano-2025-08-07",
      "gpt-4.1-2025-04-14",
    ]);
  });

  it("groups OpenAI codex variants together, after non-codex of same version line", () => {
    // codex は family=1、非 codex (gpt) は family=0。同じプロバイダ内では
    // gpt-5.X のあとに codex ブロックが来る。
    const out = sorted(["gpt-5.4-2026-03-05", "gpt-5.3-codex", "gpt-5"]);
    expect(out[0]).toBe("gpt-5.4-2026-03-05");
    expect(out[1]).toBe("gpt-5");
    expect(out[2]).toBe("gpt-5.3-codex");
  });

  it("places o-series after gpt-* and codex within OpenAI group", () => {
    const out = sorted(["o3-2025-04-16", "gpt-5", "o4-mini-2025-04-16"]);
    expect(out[0]).toBe("gpt-5");
    // o4 は major=4、o3 は major=3、降順なので o4 → o3
    expect(out[1]).toBe("o4-mini-2025-04-16");
    expect(out[2]).toBe("o3-2025-04-16");
  });

  it("falls back to lexical order for unknown model ids", () => {
    expect(sorted(["zebra-7b", "alpaca-13b", "llama-2"])).toEqual([
      "alpaca-13b",
      "llama-2",
      "zebra-7b",
    ]);
  });
});

describe("self-hosted provider helpers", () => {
  it("isSelfHostedProvider matches by `-self-hosted` suffix", () => {
    expect(isSelfHostedProvider("openai-self-hosted")).toBe(true);
    expect(isSelfHostedProvider("anthropic-self-hosted")).toBe(true);
    expect(isSelfHostedProvider("google-self-hosted")).toBe(true);
    // 命名規約に乗っていないものは false(将来 self-hosted を増やす
    // ときは provider 名側で suffix を付ける運用)
    expect(isSelfHostedProvider("openai")).toBe(false);
    expect(isSelfHostedProvider("anthropic")).toBe(false);
    expect(isSelfHostedProvider("ollama")).toBe(false);
    expect(isSelfHostedProvider("")).toBe(false);
  });

  it("providerDisplayLabel attaches `(self-hosted)` for any -self-hosted provider", () => {
    expect(providerDisplayLabel("openai-self-hosted")).toBe(
      "openai (self-hosted)",
    );
    expect(providerDisplayLabel("anthropic-self-hosted")).toBe(
      "anthropic (self-hosted)",
    );
    expect(providerDisplayLabel("openai")).toBe("openai");
  });

  it("providerVendor strips -self-hosted suffix to look up the vendor logo", () => {
    expect(providerVendor("openai-self-hosted")).toBe("openai");
    expect(providerVendor("anthropic-self-hosted")).toBe("claude");
    expect(providerVendor("google-self-hosted")).toBe("gemini");
    expect(providerVendor("openai")).toBe("openai");
    expect(providerVendor("anthropic")).toBe("claude");
    expect(providerVendor("custom")).toBeUndefined();
  });

  it("runBadges appends `(self-hosted)` to the model's own vendor label, not the provider base", () => {
    // ★ provider 文字列(`openai-self-hosted` 等)の base は API protocol を
    // 表すだけで、model 自体の vendor とは独立。例えば LM Studio で
    // gemma-3-27b を動かすと provider=openai-self-hosted, model=google/gemma-3-27b
    // となり、vendor label は "openai (self-hosted)" ではなく
    // 「gemma の vendor」=「google (self-hosted)」と出るのが正しい。
    const m = fakeMeta({
      matrixId: "bare/gemma-3-27b",
      model: "google/gemma-3-27b",
      provider: "openai-self-hosted",
    });
    const segs = runBadges(m);
    expect(segs.find((s) => s.kind === "vendor")?.label).toBe(
      "google (self-hosted)",
    );
  });

  it("runGroupProvider returns provider as-is for non-self-hosted runs", () => {
    expect(
      runGroupProvider(fakeMeta({ provider: "anthropic", model: "claude-opus-4-7" })),
    ).toBe("anthropic");
    expect(
      runGroupProvider(fakeMeta({ provider: "openai", model: "gpt-5.5" })),
    ).toBe("openai");
    expect(
      runGroupProvider(fakeMeta({ provider: "google", model: "gemini-3-pro" })),
    ).toBe("google");
  });

  it("runGroupProvider derives a `<vendor>-self-hosted` key from the model when provider is self-hosted", () => {
    // ★ LM Studio (= openai-self-hosted protocol) で gemma を動かすと
    // 一覧グルーピング上は openai-self-hosted ではなく google-self-hosted の
    // バケツに入っていてほしい。
    expect(
      runGroupProvider(
        fakeMeta({ provider: "openai-self-hosted", model: "google/gemma-3-27b" }),
      ),
    ).toBe("google-self-hosted");
    // openai/gpt-oss-20b on the same protocol stays in openai-self-hosted.
    expect(
      runGroupProvider(
        fakeMeta({ provider: "openai-self-hosted", model: "openai/gpt-oss-20b" }),
      ),
    ).toBe("openai-self-hosted");
    // Claude weights on a hypothetical anthropic-self-hosted protocol map to anthropic.
    expect(
      runGroupProvider(
        fakeMeta({ provider: "anthropic-self-hosted", model: "claude-opus-4-7" }),
      ),
    ).toBe("anthropic-self-hosted");
  });

  it("runGroupProvider falls back to `self-hosted` when model vendor cannot be inferred", () => {
    expect(
      runGroupProvider(
        fakeMeta({ provider: "openai-self-hosted", model: "lmstudio-community/some-random-7b" }),
      ),
    ).toBe("self-hosted");
  });

  it("runBadges keeps the existing chat-product vendor name when self-hosted (claude / gemini / openai)", () => {
    // 同じく、provider が openai-self-hosted で model が claude-opus-4-7
    // (slash 無し familar 形式)のとき、parseModelLabel は vendor="claude"
    // (chat product 名)を返す。runBadges は「claude (self-hosted)」を
    // 付けるべきで、provider base の「openai」ではない。
    const m = fakeMeta({
      matrixId: "bare/claude-opus-4-7",
      model: "claude-opus-4-7",
      provider: "anthropic-self-hosted",
    });
    const segs = runBadges(m);
    expect(segs.find((s) => s.kind === "vendor")?.label).toBe(
      "claude (self-hosted)",
    );
  });
});
