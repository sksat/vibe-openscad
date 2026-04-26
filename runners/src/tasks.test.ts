import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { computeTaskHash, loadAllTasks, loadTaskFile } from "./tasks.js";

let dir: string;

beforeEach(() => {
  dir = mkdtempSync(join(tmpdir(), "tasks-test-"));
});

afterEach(() => {
  rmSync(dir, { recursive: true, force: true });
});

const validTaskYaml = `
id: tier-1-cube-with-hole
tier: 1
title: Cube with through hole
prompt: |
  OpenSCAD で 50mm 角の立方体の中央に直径 20mm の貫通穴を z 軸方向に開けたモデル。
`;

describe("loadTaskFile", () => {
  it("parses a valid YAML task file", () => {
    const p = join(dir, "task.yml");
    writeFileSync(p, validTaskYaml);
    const task = loadTaskFile(p);
    expect(task.id).toBe("tier-1-cube-with-hole");
    expect(task.tier).toBe(1);
    expect(task.title).toBe("Cube with through hole");
  });

  it("rejects malformed YAML with a helpful error", () => {
    const p = join(dir, "broken.yml");
    writeFileSync(p, "id: x\ntier: not-a-number\n");
    expect(() => loadTaskFile(p)).toThrow(/broken\.yml/);
  });

  it("rejects YAML missing required fields", () => {
    const p = join(dir, "empty.yml");
    writeFileSync(p, "id: x\n");
    expect(() => loadTaskFile(p)).toThrow();
  });
});

describe("loadAllTasks", () => {
  it("walks tier directories and loads every task YAML", () => {
    mkdirSync(join(dir, "tier-1"));
    mkdirSync(join(dir, "tier-2"));
    writeFileSync(join(dir, "tier-1", "01-cube.yml"), validTaskYaml);
    writeFileSync(
      join(dir, "tier-2", "01-mug.yml"),
      `id: tier-2-mug\ntier: 2\ntitle: Mug\nprompt: make a mug\n`,
    );
    const tasks = loadAllTasks(dir);
    expect(tasks.map((t) => t.id).sort()).toEqual([
      "tier-1-cube-with-hole",
      "tier-2-mug",
    ]);
  });

  it("rejects duplicate task ids across files", () => {
    writeFileSync(join(dir, "a.yml"), validTaskYaml);
    writeFileSync(join(dir, "b.yml"), validTaskYaml);
    expect(() => loadAllTasks(dir)).toThrow(/duplicate.*tier-1-cube-with-hole/);
  });

  it("returns [] when tasks directory is empty", () => {
    expect(loadAllTasks(dir)).toEqual([]);
  });

  it("ignores non-yaml files", () => {
    writeFileSync(join(dir, "README.md"), "ignore me");
    writeFileSync(join(dir, "task.yml"), validTaskYaml);
    expect(loadAllTasks(dir)).toHaveLength(1);
  });
});

describe("computeTaskHash", () => {
  it("returns a 64-char hex string", () => {
    const task = {
      id: "x",
      tier: 1,
      title: "t",
      prompt: "p",
    };
    expect(computeTaskHash(task)).toMatch(/^[0-9a-f]{64}$/);
  });

  it("is stable across calls", () => {
    const task = { id: "x", tier: 1, title: "t", prompt: "p" };
    expect(computeTaskHash(task)).toBe(computeTaskHash(task));
  });

  it("changes when any field changes", () => {
    const a = computeTaskHash({ id: "x", tier: 1, title: "t", prompt: "p" });
    const b = computeTaskHash({ id: "x", tier: 1, title: "t", prompt: "P" });
    expect(a).not.toBe(b);
  });

  it("does not depend on field declaration order", () => {
    const a = computeTaskHash({ id: "x", tier: 1, title: "t", prompt: "p" });
    const b = computeTaskHash({
      prompt: "p",
      title: "t",
      tier: 1,
      id: "x",
    } as never);
    expect(a).toBe(b);
  });
});
