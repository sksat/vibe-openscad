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

  it("aligns the run-detail link to the right of the title in the same row", () => {
    // header は flex 横並び、.runlink は margin-left: auto で右寄せ。
    expect(SRC).toMatch(/\.bare-section header\s*\{[^}]*display:\s*flex/);
    expect(SRC).not.toMatch(/\.bare-section header\s*\{[^}]*flex-direction:\s*column/);
    expect(SRC).toMatch(/\.runlink[\s\S]*?margin-left:\s*auto/);
  });

  it("styles a visibly thicker scrollbar on .scad-scroll", () => {
    // 既定の dark background だとスクロールバーが見えにくい。明示する。
    expect(SRC).toMatch(/\.scad-scroll[\s\S]*?scrollbar-color:/);
    expect(SRC).toMatch(/::-webkit-scrollbar/);
  });

  it("uses identical flex gap on both columns so col-label + box top aligns", () => {
    // .bare-render-col に gap: 10px があり .bare-scad-col に無いと、
    // col-label の下端から render-frame までと scad-scroll までで
    // 10px ずれる。両 col に同じ gap を当てて揃える。
    const gapOnRender = SRC.match(/\.bare-render-col[\s\S]*?gap:\s*(\d+px)/);
    const gapOnScad = SRC.match(/\.bare-scad-col[\s\S]*?gap:\s*(\d+px)/);
    expect(gapOnRender?.[1]).toBeDefined();
    expect(gapOnScad?.[1]).toBe(gapOnRender?.[1]);
  });

  it("always shows the vertical scrollbar (overflow-y: scroll) for size cue", () => {
    // \`overflow: auto\` だとコードが収まったときバーが消えて
    // 「どれくらい大きい SCAD か」の視覚的手掛かりが消える。
    // 縦バーは常に出して、横は wrap してるので auto で十分。
    expect(SRC).toMatch(/\.scad-scroll[\s\S]*?overflow-y:\s*scroll/);
  });

  it("ensures the bare-scad-col cannot push the grid wider than its 1fr share", () => {
    // The Code (Shiki) output can include long unwrappable lines; without
    // min-width: 0 on the grid item, it can blow out past the column and
    // squeeze the render column.
    expect(SRC).toMatch(/\.bare-scad-col[\s\S]*?min-width:\s*0/);
  });

  it("aligns the top of the SCAD scroll with the top of the render frame via matched-height column labels", async () => {
    // SCAD 列と render 列の両方が、最初の要素として同じ意味の小さい
    // ラベル(.col-label)を持っていれば、scad-scroll の top と
    // render-frame の top が同じ y 座標にそろう。
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
    // bare-render-col の中で render-frame より前に col-label が出る
    const renderColIdx = html.indexOf("bare-render-col");
    const renderFrameIdx = html.indexOf("render-frame", renderColIdx);
    const renderLabelIdx = html.indexOf("col-label", renderColIdx);
    expect(renderLabelIdx).toBeGreaterThan(renderColIdx);
    expect(renderLabelIdx).toBeLessThan(renderFrameIdx);
    // bare-scad-col の中でも col-label が scad-scroll より前
    const scadColIdx = html.indexOf("bare-scad-col");
    const scadScrollIdx = html.indexOf("scad-scroll", scadColIdx);
    const scadLabelIdx = html.indexOf("col-label", scadColIdx);
    expect(scadLabelIdx).toBeGreaterThan(scadColIdx);
    expect(scadLabelIdx).toBeLessThan(scadScrollIdx);
  });

  it("places scad-meta ABOVE the scroll container (sibling, not nested)", async () => {
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
    expect(metaIdx).toBeGreaterThan(0);
    // meta が scroll の前 (above) に出てくる
    expect(metaIdx).toBeLessThan(scrollIdx);
  });
});
