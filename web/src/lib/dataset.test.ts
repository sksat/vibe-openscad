import { describe, expect, it } from "vitest";
import type { RunMeta } from "@vibe-openscad/runners/src/schema.js";
import {
  effortInfoFor,
  formatCost,
  parseMatrixId,
  runBadges,
  shortModelLabel,
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
