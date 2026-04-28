import { experimental_AstroContainer as AstroContainer } from "astro/container";
import { describe, expect, it } from "vitest";
import ScadCode from "./ScadCode.astro";

const SCAD = "$fn = 100;\nmodule mug() {\n  cube(10);\n}\n";

describe("ScadCode", () => {
  it("renders the SCAD without error markers when errorMessage is empty", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(ScadCode, {
      props: { scad: SCAD },
    });
    expect(html).not.toContain("line-error");
    expect(html).not.toContain("data-error");
  });

  it("marks the lines referenced in the parser error with line-error + data-error", async () => {
    const c = await AstroContainer.create();
    const errorMsg =
      "ERROR: Parser error: syntax error in file input.scad, line 3\nCan't parse file '/tmp/.../input.scad'!\n";
    const html = await c.renderToString(ScadCode, {
      props: { scad: SCAD, errorMessage: errorMsg },
    });
    // Shiki emits one <span class="line"> per source line; line 3 should
    // additionally carry the .line-error class + data-error attr.
    expect(html).toContain("line-error");
    expect(html).toMatch(/data-error="[^"]*Parser error[^"]*"/);
  });

  it("attaches markers to multiple TRACE frame lines independently", async () => {
    const errorMsg = `TRACE: call of 'cylinder()' in file input.scad, line 1
TRACE: called by 'difference' in file input.scad, line 3`;
    const c = await AstroContainer.create();
    const html = await c.renderToString(ScadCode, {
      props: { scad: SCAD, errorMessage: errorMsg },
    });
    // 2 distinct lines marked
    const errCount = (html.match(/line-error/g) ?? []).length;
    expect(errCount).toBeGreaterThanOrEqual(2);
  });

  it("does not break when error references a line outside the SCAD range", async () => {
    const c = await AstroContainer.create();
    const html = await c.renderToString(ScadCode, {
      props: {
        scad: SCAD,
        errorMessage: "ERROR: foo in file input.scad, line 999",
      },
    });
    // Out-of-range error line is silently ignored — no marker attached.
    expect(html).not.toContain("line-error");
  });
});
