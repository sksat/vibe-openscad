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

  it("does not combine container-type with aspect-ratio (broke render-frame collapse)", () => {
    // Symptom: with `container-type: inline-size` on .bare-body the
    // render-frame's aspect-ratio occasionally collapsed to its content
    // width (= the "no render" text), squeezing the column and pushing
    // meta panel content sideways. Use viewport-relative units instead.
    expect(SRC).not.toMatch(/container-type:\s*inline-size/);
  });

  it("caps SCAD scroll height with a viewport-relative unit (vh) not cqw", () => {
    // cqw depends on container-type which we drop above. Use vh as the
    // primary cap so the layout is invariant across hot-reload + zoom.
    expect(SRC).not.toMatch(/max-height:\s*\d+cqw/);
    expect(SRC).toMatch(/\.scad-scroll[\s\S]{0,200}max-height:\s*\d+vh/);
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
