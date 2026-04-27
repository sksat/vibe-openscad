import { experimental_AstroContainer as AstroContainer } from "astro/container";
import type { RunMeta } from "@vibe-openscad/runners/src/schema.js";
import { describe, expect, it } from "vitest";
import type { LoadedRun } from "../lib/results.js";
import ModelTaskCard from "./ModelTaskCard.astro";

function fakeMeta(overrides: Partial<RunMeta> = {}): RunMeta {
  const base: RunMeta = {
    runId: "bare_claude-opus-4-7-abc123-2026-04-01T00-00-00-000Z",
    taskId: "tier-1-mug",
    matrixId: "bare/claude-opus-4-7",
    signature: "a".repeat(64),
    fingerprint: {
      schemaVersion: 1,
      taskHash: "b".repeat(64),
      harness: { kind: "bare", provider: "anthropic", model: "claude-opus-4-7" },
      openscadVersion: "OpenSCAD 2024",
      promptTemplateHash: "c".repeat(64),
    },
    provider: "anthropic",
    model: "claude-opus-4-7",
    harness: { kind: "bare" },
    status: "success",
    timing: { totalMs: 2300 },
    tokens: { input: 116, output: 63 },
    cost_usd: 0.0022,
    createdAt: "2026-04-01T00:00:00.000Z",
  };
  return { ...base, ...overrides };
}

function fakeRun(overrides: Partial<RunMeta> = {}): LoadedRun {
  const meta = fakeMeta(overrides);
  return {
    meta,
    scadUrl: `/results/${meta.taskId}/${meta.runId}/final.scad`,
    pngUrl: `/results/${meta.taskId}/${meta.runId}/final.png`,
  };
}

describe("ModelTaskCard hover preview", () => {
  it("renders a hover-card with preview image + meta for each iter step", async () => {
    const container = await AstroContainer.create();
    const iterStep1 = fakeRun({
      runId: "iter-png-1_x-2026",
      matrixId: "iter-png-1/claude-opus-4-7",
      timing: { totalMs: 5400 },
      tokens: { input: 222, output: 211 },
      cost_usd: 0.006,
    });
    const html = await container.renderToString(ModelTaskCard, {
      props: {
        bare: fakeRun(),
        strategies: [
          {
            groupSlug: "iter-png",
            tail: iterStep1,
            iterSteps: [{ run: iterStep1, depth: 1 }],
            expectedDepth: 1,
          },
        ],
        variantRows: [],
        tier: 1,
      },
    });
    // hover-card wrapper present
    expect(html).toContain("hover-card");
    // larger preview image referencing the iter step's PNG
    expect(html).toContain("hover-img");
    expect(html).toContain(iterStep1.pngUrl ?? "");
    // basic meta — duration, tokens, cost
    expect(html).toContain("5.4s");
    expect(html).toContain("222/211t");
    expect(html).toContain("$0.0060");
    // step label "iter 1"
    expect(html).toMatch(/iter\s*1/);
  });

  it("renders a hover-card on variant thumbs as well (effort row)", async () => {
    const container = await AstroContainer.create();
    const variantRun = fakeRun({
      runId: "bare-low_x-2026",
      matrixId: "bare-low/claude-opus-4-7",
      timing: { totalMs: 1800 },
      tokens: { input: 100, output: 40 },
      cost_usd: 0.0014,
    });
    const html = await container.renderToString(ModelTaskCard, {
      props: {
        bare: fakeRun(),
        strategies: [],
        variantRows: [
          {
            familySlug: "effort",
            expectedLabels: ["low"],
            variants: [{ label: "low", run: variantRun }],
          },
        ],
        tier: 1,
      },
    });
    expect(html).toContain("hover-card");
    expect(html).toContain("hover-img");
    expect(html).toContain(variantRun.pngUrl ?? "");
    // variant label "low" present in tooltip + thumb
    expect(html).toMatch(/effort.*low|low.*effort/s);
    expect(html).toContain("1.8s");
  });

  it("does not put hover-card on placeholder slots (not run)", async () => {
    const container = await AstroContainer.create();
    const iter1 = fakeRun({
      runId: "iter-png-1_x-2026",
      matrixId: "iter-png-1/claude-opus-4-7",
    });
    const html = await container.renderToString(ModelTaskCard, {
      props: {
        bare: fakeRun(),
        strategies: [
          {
            groupSlug: "iter-png",
            tail: iter1,
            iterSteps: [{ run: iter1, depth: 1 }],
            // expected depth is 3 but only iter-1 ran → 2 placeholders
            expectedDepth: 3,
          },
        ],
        variantRows: [],
        tier: 1,
      },
    });
    // hover-card は走った step (1 個) にだけ付き、placeholder には付かない
    const hoverCount = (html.match(/hover-card/g) ?? []).length;
    expect(hoverCount).toBe(1);
    // placeholder のラベルは依然出る
    expect(html).toMatch(/i2/);
    expect(html).toMatch(/i3/);
  });
});
