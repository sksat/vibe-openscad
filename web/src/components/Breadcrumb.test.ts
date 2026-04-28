import { experimental_AstroContainer as AstroContainer } from "astro/container";
import { describe, expect, it } from "vitest";
import Breadcrumb from "./Breadcrumb.astro";

describe("Breadcrumb", () => {
  it("renders a nav with aria-label='breadcrumb' wrapping an ordered list", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(Breadcrumb, {
      props: {
        items: [
          { label: "home", href: "/" },
          { label: "task X" },
        ],
      },
    });
    expect(html).toMatch(/<nav[^>]+aria-label="breadcrumb"/);
    expect(html).toContain("<ol");
  });

  it("renders linked items for everything except the last one", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(Breadcrumb, {
      props: {
        items: [
          { label: "home", href: "/" },
          { label: "task A", href: "/tasks/A" },
          { label: "claude opus 4.7" }, // current — no href
        ],
      },
    });
    expect(html).toContain('href="/"');
    expect(html).toContain('href="/tasks/A"');
    // current page has aria-current
    expect(html).toMatch(/aria-current="page"[^>]*>claude opus 4\.7/);
    // current page should not be a link
    const aroundCurrent =
      html.match(/aria-current="page"[\s\S]{0,200}/)?.[0] ?? "";
    expect(aroundCurrent).not.toMatch(/<a\b/);
  });

  it("inserts a › separator between items", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(Breadcrumb, {
      props: {
        items: [
          { label: "home", href: "/" },
          { label: "tasks", href: "/tasks" },
          { label: "tier-1-mug" },
        ],
      },
    });
    // Each separator is rendered as `›` (or its HTML entity), one fewer
    // than item count.
    const sepCount = (html.match(/›/g) ?? []).length;
    expect(sepCount).toBeGreaterThanOrEqual(2);
  });

  it("collapses to a single non-link element when items has length 1", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(Breadcrumb, {
      props: { items: [{ label: "only one" }] },
    });
    expect(html).toMatch(/aria-current="page"[^>]*>only one/);
    expect(html).not.toContain("›");
  });
});
