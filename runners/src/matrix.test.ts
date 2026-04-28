import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { expandMatrix, loadBenchConfig } from "./matrix.js";
import type { Task } from "./schema.js";

let dir: string;

beforeEach(() => {
  dir = mkdtempSync(join(tmpdir(), "matrix-test-"));
});

afterEach(() => {
  rmSync(dir, { recursive: true, force: true });
});

describe("loadBenchConfig", () => {
  it("parses a valid bench-config.yml", () => {
    const yml = `
defaults:
  samples: 2
  timeoutSec: 600
matrix:
  - id: claude-bare
    harness: { kind: bare }
    provider: anthropic
    model: claude-opus-4-7
  - id: claude-cc
    harness: { kind: external-agent, agent: claude-code, maxTurns: 8 }
tasks:
  - tier: 1
`;
    const p = join(dir, "bench-config.yml");
    writeFileSync(p, yml);
    const cfg = loadBenchConfig(p);
    expect(cfg.defaults.samples).toBe(2);
    expect(cfg.matrix).toHaveLength(2);
    expect(cfg.tasks).toHaveLength(1);
  });

  it("rejects malformed config with helpful path", () => {
    const p = join(dir, "broken.yml");
    writeFileSync(p, "matrix: []\ntasks: []\n");
    expect(() => loadBenchConfig(p)).toThrow(/broken\.yml/);
  });
});

describe("expandMatrix", () => {
  const tasks: Task[] = [
    { id: "tier-1-cube", tier: 1, title: "Cube", prompt: "p1" },
    { id: "tier-1-mug", tier: 1, title: "Mug", prompt: "p2" },
    { id: "tier-2-gear", tier: 2, title: "Gear", prompt: "p3" },
  ];

  it("expands tier selectors to all tasks of that tier", () => {
    const candidates = expandMatrix(
      {
        defaults: { samples: 1, timeoutSec: 300, concurrency: { global: 4, perProvider: { anthropic: 2 } } },
        matrix: [
          {
            id: "claude-bare",
            harness: { kind: "bare" },
            provider: "anthropic",
            model: "m",
          },
        ],
        tasks: [{ tier: 1 }],
      },
      tasks,
    );
    expect(candidates).toHaveLength(2);
    expect(candidates.map((c) => c.task.id).sort()).toEqual([
      "tier-1-cube",
      "tier-1-mug",
    ]);
  });

  it("expands id selectors to that single task", () => {
    const candidates = expandMatrix(
      {
        defaults: { samples: 1, timeoutSec: 300, concurrency: { global: 4, perProvider: { anthropic: 2 } } },
        matrix: [
          {
            id: "x",
            harness: { kind: "bare" },
            provider: "p",
            model: "m",
          },
        ],
        tasks: [{ id: "tier-2-gear" }],
      },
      tasks,
    );
    expect(candidates).toHaveLength(1);
    expect(candidates[0]?.task.id).toBe("tier-2-gear");
  });

  it("multiplies matrix entries with task selectors", () => {
    const candidates = expandMatrix(
      {
        defaults: { samples: 1, timeoutSec: 300, concurrency: { global: 4, perProvider: { anthropic: 2 } } },
        matrix: [
          {
            id: "claude-bare",
            harness: { kind: "bare" },
            provider: "anthropic",
            model: "m",
          },
          {
            id: "claude-cc",
            harness: { kind: "external-agent", agent: "claude-code", maxTurns: 8 },
          },
        ],
        tasks: [{ tier: 1 }],
      },
      tasks,
    );
    expect(candidates).toHaveLength(4); // 2 entries * 2 tier-1 tasks
  });

  it("throws if a task id selector references a missing task", () => {
    expect(() =>
      expandMatrix(
        {
          defaults: { samples: 1, timeoutSec: 300, concurrency: { global: 4, perProvider: { anthropic: 2 } } },
          matrix: [
            {
              id: "x",
              harness: { kind: "bare" },
              provider: "p",
              model: "m",
            },
          ],
          tasks: [{ id: "no-such-task" }],
        },
        tasks,
      ),
    ).toThrow(/no-such-task/);
  });

  it("throws if a tier selector matches no tasks", () => {
    expect(() =>
      expandMatrix(
        {
          defaults: { samples: 1, timeoutSec: 300, concurrency: { global: 4, perProvider: { anthropic: 2 } } },
          matrix: [
            {
              id: "x",
              harness: { kind: "bare" },
              provider: "p",
              model: "m",
            },
          ],
          tasks: [{ tier: 99 }],
        },
        tasks,
      ),
    ).toThrow(/tier 99/);
  });
});
