import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { experimental_AstroContainer as AstroContainer } from "astro/container";
import { describe, expect, it } from "vitest";
import BareSection from "./BareSection.astro";

const SRC = readFileSync(
  resolve("src/components/BareSection.astro"),
  "utf8",
);

const SAMPLE_SCAD = "cube(10);\nsphere(5);\n";

describe("BareSection layout", () => {
  it("has render and scad columns as direct siblings of .bare-body", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(BareSection, {
      props: {
        pngUrl: "/img.png",
        scad: SAMPLE_SCAD,
        runId: "r-1",
        status: "success",
        taskId: "tier-1-mug",
      },
    });
    expect(html).toContain("bare-render-col");
    expect(html).toContain("bare-scad-col");
  });

  it("wraps the render in a fixed-aspect frame so 'no render' keeps shape", async () => {
    // Both rendered and not-rendered states should occupy the same 4:3
    // box so the layout below (meta panel, sibling SCAD col) is stable.
    const c = await AstroContainer.create();
    const withImg = await c.renderToString(BareSection, {
      props: {
        pngUrl: "/img.png",
        scad: SAMPLE_SCAD,
        runId: "r-1",
        status: "success",
        taskId: "tier-1-mug",
        durationMs: 1000,
      },
    });
    const noImg = await c.renderToString(BareSection, {
      props: {
        pngUrl: undefined,
        scad: SAMPLE_SCAD,
        runId: "r-2",
        status: "render_error",
        taskId: "tier-1-mug",
        durationMs: 1000,
        errorMessage: "boom",
      },
    });
    // both should have the render-frame wrapper
    expect(withImg).toContain("render-frame");
    expect(noImg).toContain("render-frame");
    // no render placeholder still announces "no render"
    expect(noImg).toContain("no render");
  });

  it("renders a meta panel with duration, tokens, cost, and error", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(BareSection, {
      props: {
        pngUrl: undefined,
        scad: SAMPLE_SCAD,
        runId: "r-2",
        status: "render_error",
        taskId: "tier-1-mug",
        durationMs: 12340,
        tokens: { input: 200, output: 1500 },
        costUsd: 0.0123,
        errorMessage:
          "ERROR: Parser error: syntax error in file input.scad, line 41",
      },
    });
    expect(html).toContain("render-meta");
    expect(html).toContain("12.3s");
    expect(html).toContain("200/1500t");
    expect(html).toContain("$0.0123");
    expect(html).toMatch(/Parser error/);
  });

  it("does not put container-type on .bare-body (broke render-frame aspect-ratio)", () => {
    // Putting container-type: inline-size on .bare-body affected
    // .render-frame in the sibling column — aspect-ratio occasionally
    // collapsed to text width. Container-type may live on .bare-scad-col
    // itself (no aspect-ratio child there), but never on the grid parent.
    expect(SRC).not.toMatch(/\.bare-body\s*\{[^}]*container-type:\s*inline-size/);
  });

  it("caps SCAD scroll height proportional to column width (~ 2× render frame)", () => {
    // render-frame is aspect-ratio 4/3 → render height = col-width × 0.75.
    // SCAD scroll max should approximate 2 × that = col-width × 1.5
    // = 150cqw, when container-type is scoped to .bare-scad-col.
    expect(SRC).toMatch(/\.bare-scad-col[\s\S]*?container-type:\s*inline-size/);
    expect(SRC).toMatch(/max-height:\s*150cqw/);
  });

  it("stacks the run-detail link below the title (not right-aligned in the same row)", () => {
    // \"run detail →\" は h2 (bare ...) の直下に置きたい。flex-direction:
    // column が指定されていて、.runlink の margin-left: auto が無いことを
    // 担保する。
    expect(SRC).toMatch(/\.bare-section header[\s\S]*?flex-direction:\s*column/);
    expect(SRC).not.toMatch(/\.runlink[\s\S]*?margin-left:\s*auto/);
  });

  it("styles a visibly thicker scrollbar on .scad-scroll", () => {
    // 既定の dark background だとスクロールバーが見えにくい。明示する。
    expect(SRC).toMatch(/\.scad-scroll[\s\S]*?scrollbar-color:/);
    expect(SRC).toMatch(/::-webkit-scrollbar/);
  });

  it("ensures the bare-scad-col cannot push the grid wider than its 1fr share", () => {
    // The Code (Shiki) output can include long unwrappable lines; without
    // min-width: 0 on the grid item, it can blow out past the column and
    // squeeze the render column.
    expect(SRC).toMatch(/\.bare-scad-col[\s\S]*?min-width:\s*0/);
  });

  it("places scad-meta INSIDE the scroll container (not as a sibling above)", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(BareSection, {
      props: {
        pngUrl: "/img.png",
        scad: SAMPLE_SCAD,
        runId: "r-1",
        status: "success",
        taskId: "tier-1-mug",
        durationMs: 1000,
      },
    });
    const scrollIdx = html.indexOf("scad-scroll");
    const metaIdx = html.indexOf("scad-meta");
    expect(scrollIdx).toBeGreaterThan(0);
    expect(metaIdx).toBeGreaterThan(scrollIdx);
  });
});
