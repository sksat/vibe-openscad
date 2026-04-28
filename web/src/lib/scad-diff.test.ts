import { describe, expect, it } from "vitest";
import { lineDiff, type DiffLine } from "./scad-diff.js";

describe("lineDiff", () => {
  it("returns all 'context' lines for identical inputs", () => {
    const a = "cube(10);\nsphere(5);\n";
    const lines = lineDiff(a, a);
    expect(lines.every((l) => l.type === "context")).toBe(true);
    expect(lines.map((l) => l.text)).toEqual(["cube(10);", "sphere(5);"]);
  });

  it("marks pure additions as 'added'", () => {
    const before = "cube(10);\n";
    const after = "cube(10);\nsphere(5);\n";
    const lines = lineDiff(before, after);
    expect(lines).toEqual<DiffLine[]>([
      { type: "context", text: "cube(10);" },
      { type: "added", text: "sphere(5);" },
    ]);
  });

  it("marks pure removals as 'removed'", () => {
    const before = "cube(10);\nsphere(5);\n";
    const after = "cube(10);\n";
    const lines = lineDiff(before, after);
    expect(lines).toEqual<DiffLine[]>([
      { type: "context", text: "cube(10);" },
      { type: "removed", text: "sphere(5);" },
    ]);
  });

  it("emits a remove + add pair for a modified line", () => {
    const before = "cube([10,10,10]);\n";
    const after = "cube([20,20,20]);\n";
    const lines = lineDiff(before, after);
    const types = lines.map((l) => l.type);
    expect(types).toContain("removed");
    expect(types).toContain("added");
    expect(lines.find((l) => l.type === "removed")?.text).toBe("cube([10,10,10]);");
    expect(lines.find((l) => l.type === "added")?.text).toBe("cube([20,20,20]);");
  });

  it("counts changed lines via summary helper", () => {
    const before = "a\nb\nc\n";
    const after = "a\nx\nc\nd\n";
    const lines = lineDiff(before, after);
    const added = lines.filter((l) => l.type === "added").length;
    const removed = lines.filter((l) => l.type === "removed").length;
    expect(added).toBe(2); // x, d
    expect(removed).toBe(1); // b
  });

  it("handles empty inputs gracefully", () => {
    expect(lineDiff("", "")).toEqual([]);
    expect(lineDiff("", "x\n")).toEqual([{ type: "added", text: "x" }]);
    expect(lineDiff("x\n", "")).toEqual([{ type: "removed", text: "x" }]);
  });
});
