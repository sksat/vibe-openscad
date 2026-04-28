import { describe, expect, it } from "vitest";
import { parseScadErrors, type ScadErrorAnnotation } from "./scad-error.js";

describe("parseScadErrors", () => {
  it("returns [] for empty / null inputs", () => {
    expect(parseScadErrors("")).toEqual([]);
    expect(parseScadErrors(undefined)).toEqual([]);
    expect(parseScadErrors(null)).toEqual([]);
  });

  it("extracts a single parser error with line number", () => {
    const msg =
      "openscad stl render failed (exit 1): ERROR: Parser error: syntax error in file ../../../../../tmp/render-QTc15O/input.scad, line 70\n" +
      "Can't parse file '/tmp/render-QTc15O/input.scad'!\n";
    expect(parseScadErrors(msg)).toEqual<ScadErrorAnnotation[]>([
      {
        line: 70,
        message: "ERROR: Parser error: syntax error",
      },
    ]);
  });

  it("returns no annotations when error has no line reference", () => {
    expect(parseScadErrors("Current top level object is empty.")).toEqual([]);
  });

  it("extracts multiple TRACE frames as separate annotations", () => {
    const msg = `TRACE: call of 'cylinder(h = 90, r = 40)' in file input.scad, line 80
TRACE: called by 'difference' in file input.scad, line 24
TRACE: called by 'mug_body' in file input.scad, line 74`;
    const out = parseScadErrors(msg);
    const lines = out.map((a) => a.line).sort((a, b) => a - b);
    expect(lines).toEqual([24, 74, 80]);
    // each annotation includes the trace context
    expect(out.find((a) => a.line === 80)?.message).toMatch(/cylinder/);
  });

  it("matches both bare 'input.scad, line N' and full-path forms", () => {
    expect(
      parseScadErrors("ERROR: something in file input.scad, line 5"),
    ).toEqual([{ line: 5, message: "ERROR: something" }]);
    expect(
      parseScadErrors(
        "ERROR: something in file '/tmp/render-X/input.scad', line 12",
      ),
    ).toEqual([{ line: 12, message: "ERROR: something" }]);
  });

  it("merges multiple annotations on the same line into one entry", () => {
    const msg = `ERROR: foo in file input.scad, line 10
ERROR: bar in file input.scad, line 10`;
    const out = parseScadErrors(msg);
    expect(out).toHaveLength(1);
    expect(out[0]?.line).toBe(10);
    expect(out[0]?.message).toMatch(/foo/);
    expect(out[0]?.message).toMatch(/bar/);
  });
});
