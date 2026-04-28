import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { experimental_AstroContainer as AstroContainer } from "astro/container";
import { describe, expect, it } from "vitest";
import RunView from "./RunView.astro";

const SRC = readFileSync(
  resolve("src/components/RunView.astro"),
  "utf8",
);

const SAMPLE_SCAD = "cube(10);\nsphere(5);\n";

describe("RunView layout", () => {
  it("uses the title prop as the section heading and renders the optional subtitle", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(RunView, {
      props: {
        pngUrl: "/img.png",
        scad: SAMPLE_SCAD,
        runId: "r-1",
        status: "success",
        taskId: "tier-1-mug",
        durationMs: 1000,
        title: "claude-code",
        subtitle: "(8 turns)",
      },
    });
    // h2 タグが title を含み、subtitle が小さく付随する
    const h2 = html.match(/<h2[^>]*>([\s\S]*?)<\/h2>/)?.[1] ?? "";
    expect(h2).toContain("claude-code");
    expect(h2).toContain("(8 turns)");
  });

  it("hides the run-detail link when showRunLink is false", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(RunView, {
      props: {
        pngUrl: "/img.png",
        scad: SAMPLE_SCAD,
        runId: "r-1",
        status: "success",
        taskId: "tier-1-mug",
        durationMs: 1000,
        showRunLink: false,
      },
    });
    expect(html).not.toContain("runlink");
    expect(html).not.toContain("run detail →");
  });

  it("has render and scad columns as direct siblings of .run-view-body", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(RunView, {
      props: {
        pngUrl: "/img.png",
        scad: SAMPLE_SCAD,
        runId: "r-1",
        status: "success",
        taskId: "tier-1-mug",
      },
    });
    expect(html).toContain("run-view-render-col");
    expect(html).toContain("run-view-scad-col");
  });

  it("wraps the render in a fixed-aspect frame so 'no render' keeps shape", async () => {
    // Both rendered and not-rendered states should occupy the same 4:3
    // box so the layout below (meta panel, sibling SCAD col) is stable.
    const c = await AstroContainer.create();
    const withImg = await c.renderToString(RunView, {
      props: {
        pngUrl: "/img.png",
        scad: SAMPLE_SCAD,
        runId: "r-1",
        status: "success",
        taskId: "tier-1-mug",
        durationMs: 1000,
      },
    });
    const noImg = await c.renderToString(RunView, {
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
    const html = await c.renderToString(RunView, {
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

  it("does not put container-type on .run-view-body (broke render-frame aspect-ratio)", () => {
    // Putting container-type: inline-size on .run-view-body affected
    // .render-frame in the sibling column — aspect-ratio occasionally
    // collapsed to text width. Container-type may live on .run-view-scad-col
    // itself (no aspect-ratio child there), but never on the grid parent.
    expect(SRC).not.toMatch(/\.run-view-body\s*\{[^}]*container-type:\s*inline-size/);
  });

  it("caps SCAD scroll height proportional to column width (~ 2× render frame)", () => {
    // render-frame is aspect-ratio 4/3 → render height = col-width × 0.75.
    // SCAD scroll max should approximate 2 × that = col-width × 1.5
    // = 150cqw, when container-type is scoped to .run-view-scad-col.
    expect(SRC).toMatch(/\.run-view-scad-col[\s\S]*?container-type:\s*inline-size/);
    expect(SRC).toMatch(/max-height:\s*150cqw/);
  });

  it("aligns the run-detail link to the right of the title in the same row", () => {
    // header は flex 横並び、.runlink は margin-left: auto で右寄せ。
    expect(SRC).toMatch(/\.run-view header\s*\{[^}]*display:\s*flex/);
    expect(SRC).not.toMatch(/\.run-view header\s*\{[^}]*flex-direction:\s*column/);
    expect(SRC).toMatch(/\.runlink[\s\S]*?margin-left:\s*auto/);
  });

  it("styles a visibly thicker scrollbar on .scad-scroll", () => {
    // 既定の dark background だとスクロールバーが見えにくい。明示する。
    expect(SRC).toMatch(/\.scad-scroll[\s\S]*?scrollbar-color:/);
    expect(SRC).toMatch(/::-webkit-scrollbar/);
  });

  it("uses identical flex gap on both columns so col-label + box top aligns", () => {
    // .run-view-render-col に gap: 10px があり .run-view-scad-col に無いと、
    // col-label の下端から render-frame までと scad-scroll までで
    // 10px ずれる。両 col に同じ gap を当てて揃える。
    const gapOnRender = SRC.match(/\.run-view-render-col[\s\S]*?gap:\s*(\d+px)/);
    const gapOnScad = SRC.match(/\.run-view-scad-col[\s\S]*?gap:\s*(\d+px)/);
    expect(gapOnRender?.[1]).toBeDefined();
    expect(gapOnScad?.[1]).toBe(gapOnRender?.[1]);
  });

  it("always shows the vertical scrollbar (overflow-y: scroll) for size cue", () => {
    // \`overflow: auto\` だとコードが収まったときバーが消えて
    // 「どれくらい大きい SCAD か」の視覚的手掛かりが消える。
    // 縦バーは常に出して、横は wrap してるので auto で十分。
    expect(SRC).toMatch(/\.scad-scroll[\s\S]*?overflow-y:\s*scroll/);
  });

  it("ensures the run-view-scad-col cannot push the grid wider than its 1fr share", () => {
    // The Code (Shiki) output can include long unwrappable lines; without
    // min-width: 0 on the grid item, it can blow out past the column and
    // squeeze the render column.
    expect(SRC).toMatch(/\.run-view-scad-col[\s\S]*?min-width:\s*0/);
  });

  it("aligns the top of the SCAD scroll with the top of the render frame via matched-height column labels", async () => {
    // SCAD 列と render 列の両方が、最初の要素として同じ意味の小さい
    // ラベル(.col-label)を持っていれば、scad-scroll の top と
    // render-frame の top が同じ y 座標にそろう。
    const c = await AstroContainer.create();
    const html = await c.renderToString(RunView, {
      props: {
        pngUrl: "/img.png",
        scad: SAMPLE_SCAD,
        runId: "r-1",
        status: "success",
        taskId: "tier-1-mug",
        durationMs: 1000,
      },
    });
    // run-view-render-col の中で render-frame より前に col-label が出る
    const renderColIdx = html.indexOf("run-view-render-col");
    const renderFrameIdx = html.indexOf("render-frame", renderColIdx);
    const renderLabelIdx = html.indexOf("col-label", renderColIdx);
    expect(renderLabelIdx).toBeGreaterThan(renderColIdx);
    expect(renderLabelIdx).toBeLessThan(renderFrameIdx);
    // run-view-scad-col の中でも col-label が scad-scroll より前
    const scadColIdx = html.indexOf("run-view-scad-col");
    const scadScrollIdx = html.indexOf("scad-scroll", scadColIdx);
    const scadLabelIdx = html.indexOf("col-label", scadColIdx);
    expect(scadLabelIdx).toBeGreaterThan(scadColIdx);
    expect(scadLabelIdx).toBeLessThan(scadScrollIdx);
  });

  it("stacks the STL viewer below the PNG when stlUrl is provided (no toggle)", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(RunView, {
      props: {
        pngUrl: "/img.png",
        stlUrl: "/img.stl",
        scad: SAMPLE_SCAD,
        runId: "r-1",
        status: "success",
        taskId: "tier-1-mug",
        durationMs: 1000,
      },
    });
    // PNG/STL 切替ボタンは作らない
    expect(html).not.toMatch(/data-target="png"/);
    expect(html).not.toMatch(/data-target="stl"/);
    // PNG の下に STL viewer が出る(順序チェック)
    const renderColIdx = html.indexOf("run-view-render-col");
    const pngIdx = html.indexOf("/img.png", renderColIdx);
    const stlIdx = html.indexOf("/img.stl", renderColIdx);
    expect(pngIdx).toBeGreaterThan(renderColIdx);
    expect(stlIdx).toBeGreaterThan(pngIdx);
    // STL pane は hidden ではない(常時表示)
    const stlFrame = html.match(/stl-frame[\s\S]{0,500}/)?.[0] ?? "";
    expect(stlFrame).not.toMatch(/\bhidden\b/);
  });

  it("renders custom slot content in place of the default StlViewer when given", async () => {
    // 「stl-viewer」slot を渡せば run detail の ParametricStlViewer 等を
    // 差し込める。slot を埋めない場合は default の StlViewer が出る。
    const c = await AstroContainer.create();
    const html = await c.renderToString(RunView, {
      props: {
        pngUrl: "/img.png",
        stlUrl: "/img.stl",
        scad: SAMPLE_SCAD,
        runId: "r-1",
        status: "success",
        taskId: "tier-1-mug",
        durationMs: 1000,
      },
      slots: {
        "stl-viewer": '<div class="custom-stl-marker">slotted</div>',
      },
    });
    expect(html).toContain("custom-stl-marker");
    // default StlViewer の data-stl-src は出ない(slot に置き換わったため)
    expect(html).not.toMatch(/data-stl-src=/);
    // PNG → STL の縦並びは維持
    const pngIdx = html.indexOf("/img.png");
    const customIdx = html.indexOf("custom-stl-marker");
    expect(pngIdx).toBeGreaterThan(0);
    expect(customIdx).toBeGreaterThan(pngIdx);
  });

  it("does not render the STL viewer when stlUrl is missing", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(RunView, {
      props: {
        pngUrl: "/img.png",
        scad: SAMPLE_SCAD,
        runId: "r-1",
        status: "success",
        taskId: "tier-1-mug",
        durationMs: 1000,
      },
    });
    expect(html).not.toContain("stl-frame");
  });

  it("renders a SCAD/raw toggle when rawText is provided, defaulting to SCAD", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(RunView, {
      props: {
        pngUrl: "/img.png",
        scad: SAMPLE_SCAD,
        runId: "r-1",
        status: "success",
        taskId: "tier-1-mug",
        durationMs: 1000,
        rawText: "Here you go:\n```openscad\ncube();\n```\n",
      },
    });
    // 切替ボタンがある(button or radio)
    expect(html).toMatch(/role="tablist"|class="[^"]*toggle/);
    // SCAD と raw 両方の view tag がある
    expect(html).toMatch(/data-view="scad"/);
    expect(html).toMatch(/data-view="raw"/);
    // default は SCAD: scad view が aria-pressed/active、raw が hidden
    const scadBtn = html.match(/data-target="scad"[^>]+>/)?.[0] ?? "";
    expect(scadBtn).toMatch(/aria-pressed="true"|aria-current/);
    const rawPanel = html.match(/data-view="raw"[\s\S]{0,200}/)?.[0] ?? "";
    expect(rawPanel).toMatch(/hidden|aria-hidden="true"/);
  });

  it("does not render a toggle when rawText is not provided", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(RunView, {
      props: {
        pngUrl: "/img.png",
        scad: SAMPLE_SCAD,
        runId: "r-1",
        status: "success",
        taskId: "tier-1-mug",
        durationMs: 1000,
      },
    });
    expect(html).not.toMatch(/data-target="raw"/);
  });

  it("places scad-meta ABOVE the scroll container (sibling, not nested)", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(RunView, {
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
