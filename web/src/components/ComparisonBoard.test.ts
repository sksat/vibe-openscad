import { experimental_AstroContainer as AstroContainer } from "astro/container";
import { Window } from "happy-dom";
import { describe, expect, it } from "vitest";
import ComparisonBoard from "./ComparisonBoard.astro";
import { initComparison } from "./comparison-controller.js";
import type { ComparisonTask } from "../lib/comparison.js";

const run = { href: "/run/a", image: "/a.png", status: "success", meta: "1s" };
const tasks: ComparisonTask[] = [
  { id: "cube", title: "Cube", tier: 1, href: "/task/cube", prompt: "a cube", models: [
    { id: "a", cells: [{ key: "baseline", family: "baseline", label: "単発", run }, { key: "iter:1", family: "iter", label: "iter 1", run }] },
    { id: "b", cells: [{ key: "baseline", family: "baseline", label: "単発", run: { ...run, image: undefined, status: "render_error" } }] },
  ] },
  { id: "sphere", title: "Sphere", tier: 2, href: "/task/sphere", prompt: "a sphere", models: [] },
];
const models = ["a", "b"].map((id) => ({ id, label: id, provider: id }));

async function setup() {
  const container = await AstroContainer.create();
  const html = await container.renderToString(ComparisonBoard, { props: { tasks, models } });
  const window = new Window({ url: "https://example.test/?model=b&model=a" });
  window.document.body.innerHTML = html;
  const root = window.document.querySelector("[data-comparison]") as unknown as HTMLElement;
  initComparison(root);
  return { root, window };
}

describe("comparison interaction", () => {
  it("compares multiple tasks with shared columns and restores the task selection from the URL", async () => {
    const { root, window } = await setup();
    root.querySelector<HTMLInputElement>('[data-task-choice][value="sphere"]')!.click();
    expect([...root.querySelectorAll<HTMLElement>("[data-compare-task]")].map((el) => el.dataset["compareTask"])).toEqual(["cube", "sphere"]);
    expect([...root.querySelectorAll("thead a")].map((a) => a.textContent)).toEqual(["b", "a"]);
    expect(root.querySelectorAll('[data-task-id="sphere"][data-condition="baseline"] td')).toHaveLength(2);
    expect(new URLSearchParams(window.location.search).getAll("task")).toEqual(["cube", "sphere"]);
    expect(root.querySelector<HTMLElement>(".task-navigation")!.hidden).toBe(true);
    root.querySelector<HTMLButtonElement>("[data-clear-tasks]")!.click();
    expect(root.querySelector<HTMLElement>("[data-comparison-empty]")!.hidden).toBe(false);
    root.querySelector<HTMLButtonElement>("[data-all-tasks]")!.click();
    expect(root.querySelectorAll("[data-compare-task]")).toHaveLength(2);
    window.history.replaceState({}, "", "?task=sphere&task=cube&model=b&model=a&expanded=");
    window.dispatchEvent(new window.PopStateEvent("popstate"));
    expect([...root.querySelectorAll<HTMLElement>("[data-compare-task]")].map((el) => el.dataset["compareTask"])).toEqual(["sphere", "cube"]);
    expect(root.querySelectorAll("[data-task-choice]:checked")).toHaveLength(2);
    expect(root.querySelector('[data-condition="iter:1"]')).toBeNull();
    await window.happyDOM.abort();
  });
  it("keeps columns through task changes and restores state from browser history", async () => {
    const { root, window } = await setup();
    const headerLabels = () => [...root.querySelectorAll("thead a")].map((a) => a.textContent);
    expect(headerLabels()).toEqual(["b", "a"]);
    expect(root.querySelector('[data-condition="baseline"] td a')!.textContent).toContain("画像なし");
    root.querySelector<HTMLButtonElement>("[data-task-next]")!.click();
    expect(headerLabels()).toEqual(["b", "a"]);
    expect(root.querySelectorAll('[data-condition="baseline"] .no-render')).toHaveLength(2);
    expect(window.location.search).toContain("task=sphere");
    window.history.replaceState({}, "", "?task=cube&model=a&expanded=");
    window.dispatchEvent(new window.PopStateEvent("popstate"));
    expect(headerLabels()).toEqual(["a"]);
    expect(root.querySelector('[data-condition="iter:1"]')).toBeNull();
    root.querySelector<HTMLButtonElement>("[data-family-toggle]")!.click();
    expect(root.querySelector('[data-condition="iter:1"] img')).not.toBeNull();
    expect(window.location.search).toContain("expanded=iter");
    await window.happyDOM.abort();
  });
  it("searches choices without losing selection and supports clearing and reselecting", async () => {
    const { root, window } = await setup();
    const search = root.querySelector<HTMLInputElement>("[data-model-search]")!;
    search.value = "no-match";
    search.dispatchEvent(new window.Event("input") as unknown as Event);
    expect(root.querySelector<HTMLElement>("[data-search-empty]")!.hidden).toBe(false);
    expect(root.querySelectorAll("thead a")).toHaveLength(2);
    root.querySelector<HTMLButtonElement>("[data-clear-models]")!.click();
    expect(root.querySelector<HTMLElement>("[data-comparison-empty]")!.hidden).toBe(false);
    search.value = "";
    search.dispatchEvent(new window.Event("input") as unknown as Event);
    root.querySelector<HTMLInputElement>("[data-model-choice]")!.click();
    expect(root.querySelectorAll("thead a")).toHaveLength(1);
    expect(root.querySelector<HTMLElement>("[data-comparison-empty]")!.hidden).toBe(true);
    await window.happyDOM.abort();
  });
  it("embeds task text as JSON without allowing a closing script tag", async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(ComparisonBoard, { props: { tasks: [{ ...tasks[0]!, prompt: '</script><img src=x onerror="alert(1)">' }], models } });
    expect(html).not.toContain('<img src=x');
    expect(html).toContain('\\u003c/script>');
  });
});
