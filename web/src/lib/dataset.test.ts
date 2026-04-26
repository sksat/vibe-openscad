import { describe, expect, it } from "vitest";
import type { RunMeta } from "@vibe-openscad/runners/src/schema.js";
import { formatCost, parseMatrixId, runBadges } from "./dataset.js";

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
