import { describe, expect, it } from "vitest";
import { extractParameters } from "./scad-parameters.js";

describe("extractParameters", () => {
  it("returns [] when there are no top-level assignments", () => {
    expect(extractParameters("cube([10,10,10]);")).toEqual([]);
  });

  it("captures a top-level number variable", () => {
    const params = extractParameters("height = 100;\ncube([10,10,height]);");
    expect(params).toEqual([
      { name: "height", kind: "number", value: 100 },
    ]);
  });

  it("captures multiple numbers in source order", () => {
    const src = `
      height = 100;
      diameter = 80;
      wall = 4;
    `;
    expect(extractParameters(src).map((p) => p.name)).toEqual([
      "height",
      "diameter",
      "wall",
    ]);
  });

  it("captures booleans", () => {
    expect(extractParameters("with_lid = true;\nfilled = false;")).toEqual([
      { name: "with_lid", kind: "boolean", value: true },
      { name: "filled", kind: "boolean", value: false },
    ]);
  });

  it("ignores assignments inside module bodies", () => {
    const src = `
      outer = 50;
      module ring() {
        local = 5;
        difference() {
          cube([outer, outer, outer]);
          cube([local, local, local]);
        }
      }
    `;
    expect(extractParameters(src).map((p) => p.name)).toEqual(["outer"]);
  });

  it("ignores function() = ... declarations", () => {
    const src = `
      base = 10;
      function double(x) = x * 2;
      result = double(base);
    `;
    // Both base and result are top-level assignments. function is skipped.
    expect(extractParameters(src).map((p) => p.name)).toEqual([
      "base",
      "result",
    ]);
    // result references double() — extractor should still capture it as a
    // number-typed parameter only if its default value is a literal number.
    // Since the RHS is an expression, it should NOT be a number param.
    const r = extractParameters(src).find((p) => p.name === "result");
    expect(r?.kind).toBe("expr");
  });

  it("captures ranged number hints from // [min:max] comments", () => {
    const src = `height = 100; // [10:200]`;
    const p = extractParameters(src)[0];
    expect(p).toMatchObject({
      name: "height",
      kind: "number",
      value: 100,
      range: { min: 10, max: 200 },
    });
  });

  it("captures stepped number hints from // [min:step:max] comments", () => {
    const src = `wall = 4; // [1:0.5:8]`;
    const p = extractParameters(src)[0];
    expect(p).toMatchObject({
      name: "wall",
      kind: "number",
      value: 4,
      range: { min: 1, step: 0.5, max: 8 },
    });
  });

  it("captures negative numbers and decimals", () => {
    const src = `offset = -3.5;\nratio = 0.25;`;
    expect(extractParameters(src)).toEqual([
      { name: "offset", kind: "number", value: -3.5 },
      { name: "ratio", kind: "number", value: 0.25 },
    ]);
  });

  it("skips $-prefixed special vars by default", () => {
    const src = `$fn = 64;\nheight = 10;`;
    expect(extractParameters(src).map((p) => p.name)).toEqual(["height"]);
  });

  it("includes $-prefixed vars when includeSpecial is true", () => {
    const src = `$fn = 64;\nheight = 10;`;
    expect(
      extractParameters(src, { includeSpecial: true }).map((p) => p.name),
    ).toEqual(["$fn", "height"]);
  });
});
