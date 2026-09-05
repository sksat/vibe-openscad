import { readFileSync } from "node:fs";
import { Window, type HTMLElement, type HTMLButtonElement } from "happy-dom";
import { describe, expect, it } from "vitest";

const source = readFileSync(new URL("./Filters.astro", import.meta.url), "utf8");
const script = source.match(/<script is:inline>([\s\S]*?)<\/script>/)![1]!;

describe("filter interaction", () => {
  it("hides empty groups, announces no results, and restores results on clear", () => {
    const window = new Window({ url: "https://example.test/" });
    const doc = window.document;
    doc.body.innerHTML = `
      <details data-filter-root><button data-filter-chip data-facet="models" data-value="other">other</button>
      <button data-filter-clear>clear</button><span data-filter-status></span></details>
      <div data-filter-empty hidden></div>
      <section class="task-row"><section class="outer-group"><section class="inner-group">
      <article data-task="cube" data-models="model-a"></article>
      </section></section></section>`;
    window.eval(script);
    doc.dispatchEvent(new window.Event("DOMContentLoaded"));
    const chip = doc.querySelector("[data-filter-chip]") as HTMLButtonElement;
    chip.click();
    expect(chip.getAttribute("aria-pressed")).toBe("true");
    expect((doc.querySelector(".task-row") as HTMLElement).style.display).toBe("none");
    expect((doc.querySelector("[data-filter-empty]") as HTMLElement).hidden).toBe(false);
    (doc.querySelector("[data-filter-clear]") as HTMLButtonElement).click();
    expect(chip.getAttribute("aria-pressed")).toBe("false");
    expect((doc.querySelector(".task-row") as HTMLElement).style.display).toBe("");
    expect((doc.querySelector("[data-filter-empty]") as HTMLElement).hidden).toBe(true);
    window.happyDOM.abort();
  });
});
