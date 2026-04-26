import { describe, expect, it } from "vitest";
import { extractScad } from "./extract.js";

describe("extractScad", () => {
  it("extracts from a ```openscad fenced block", () => {
    const text = "Here is the model:\n\n```openscad\ncube([10,10,10]);\n```\n";
    expect(extractScad(text)).toBe("cube([10,10,10]);");
  });

  it("extracts from a ```scad fenced block", () => {
    const text = "```scad\ncylinder(h=10, r=5);\n```";
    expect(extractScad(text)).toBe("cylinder(h=10, r=5);");
  });

  it("extracts from an unlabeled fenced block", () => {
    const text = "Result:\n```\nsphere(r=5);\n```\nDone.";
    expect(extractScad(text)).toBe("sphere(r=5);");
  });

  it("prefers an openscad-labeled block over an earlier unlabeled block", () => {
    const text =
      "Pseudo:\n```\n// not the answer\n```\n\nActual answer:\n```openscad\ncube([1,1,1]);\n```";
    expect(extractScad(text)).toBe("cube([1,1,1]);");
  });

  it("returns null when no code block is present", () => {
    expect(extractScad("Sorry, I can't help.")).toBeNull();
  });

  it("returns null when fenced block is empty", () => {
    expect(extractScad("```openscad\n```")).toBeNull();
  });

  it("trims surrounding whitespace inside the block", () => {
    const text = "```openscad\n\n  cube([5,5,5]);\n\n```";
    expect(extractScad(text)).toBe("cube([5,5,5]);");
  });
});
