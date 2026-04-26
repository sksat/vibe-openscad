import { existsSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import {
  indexResults,
  loadRunMeta,
  pruneOldRuns,
  writeRunResult,
} from "./results.js";
import type { Fingerprint, RunMeta } from "./schema.js";

let dir: string;

beforeEach(() => {
  dir = mkdtempSync(join(tmpdir(), "results-test-"));
});

afterEach(() => {
  rmSync(dir, { recursive: true, force: true });
});

const fingerprint: Fingerprint = {
  schemaVersion: 1,
  taskHash: "a".repeat(64),
  harness: { kind: "bare", provider: "anthropic", model: "m" },
  openscadVersion: "OpenSCAD 2021.01",
  promptTemplateHash: "b".repeat(64),
};

const baseMeta: RunMeta = {
  runId: "claude-opus-bare-abc123abcdef-2026-04-27T00-00-00Z",
  taskId: "tier-1-cube-with-hole",
  matrixId: "claude-opus-bare",
  signature: "c".repeat(64),
  fingerprint,
  provider: "anthropic",
  model: "claude-opus-4-7",
  harness: { kind: "bare" },
  status: "success",
  timing: { totalMs: 1234 },
  createdAt: "2026-04-27T00:00:00Z",
};

describe("writeRunResult", () => {
  it("creates results/<task>/<run>/meta.json with prompt and final scad", () => {
    writeRunResult(dir, baseMeta, {
      prompt: "make a cube",
      finalScad: "cube([10,10,10]);",
    });
    const runDir = join(dir, baseMeta.taskId, baseMeta.runId);
    expect(existsSync(join(runDir, "meta.json"))).toBe(true);
    expect(readFileSync(join(runDir, "prompt.md"), "utf8")).toBe("make a cube");
    expect(readFileSync(join(runDir, "final.scad"), "utf8")).toBe(
      "cube([10,10,10]);",
    );
  });

  it("writes meta.json that round-trips through loadRunMeta", () => {
    writeRunResult(dir, baseMeta, { prompt: "x", finalScad: "y" });
    const loaded = loadRunMeta(
      join(dir, baseMeta.taskId, baseMeta.runId, "meta.json"),
    );
    expect(loaded).toEqual(baseMeta);
  });

  it("rejects writing twice into the same runId directory", () => {
    writeRunResult(dir, baseMeta, { prompt: "x", finalScad: "y" });
    expect(() =>
      writeRunResult(dir, baseMeta, { prompt: "x", finalScad: "y" }),
    ).toThrow();
  });

  it("optionally writes binary final.stl and final.png", () => {
    writeRunResult(dir, baseMeta, {
      prompt: "x",
      finalScad: "y",
      finalStl: Buffer.from("stl-bytes"),
      finalPng: Buffer.from("png-bytes"),
    });
    const runDir = join(dir, baseMeta.taskId, baseMeta.runId);
    expect(readFileSync(join(runDir, "final.stl"))).toEqual(
      Buffer.from("stl-bytes"),
    );
    expect(readFileSync(join(runDir, "final.png"))).toEqual(
      Buffer.from("png-bytes"),
    );
  });
});

describe("writeRunResult with iterations", () => {
  it("writes iteration artifacts to iterations/NN/", () => {
    const meta: RunMeta = {
      ...baseMeta,
      iterations: [
        { index: 1, status: "render_error", durationMs: 100, error: "boom" },
        { index: 2, status: "success", durationMs: 200 },
      ],
    };
    writeRunResult(dir, meta, {
      prompt: "p",
      finalScad: "cube(); // v2",
      iterations: [
        {
          meta: { index: 1, status: "render_error", durationMs: 100, error: "boom" },
          artifacts: { scad: "cube(); // broken", note: "first attempt" },
        },
        {
          meta: { index: 2, status: "success", durationMs: 200 },
          artifacts: {
            scad: "cube(); // v2",
            stl: Buffer.from("STL"),
            png: Buffer.from("PNG"),
            note: "fixed via feedback",
          },
        },
      ],
    });
    const runDir = join(dir, meta.taskId, meta.runId);
    expect(existsSync(join(runDir, "iterations", "01", "input.scad"))).toBe(true);
    expect(existsSync(join(runDir, "iterations", "01", "note.md"))).toBe(true);
    expect(existsSync(join(runDir, "iterations", "02", "render.stl"))).toBe(true);
    expect(existsSync(join(runDir, "iterations", "02", "render.png"))).toBe(true);
    // round-trip via loadRunMeta
    const loaded = loadRunMeta(join(runDir, "meta.json"));
    expect(loaded.iterations?.length).toBe(2);
    expect(loaded.iterations?.[1]?.status).toBe("success");
  });

  it("works for bare runs without iterations (omits the field)", () => {
    writeRunResult(dir, baseMeta, { prompt: "p", finalScad: "s" });
    const loaded = loadRunMeta(
      join(dir, baseMeta.taskId, baseMeta.runId, "meta.json"),
    );
    expect(loaded.iterations).toBeUndefined();
  });
});

describe("pruneOldRuns", () => {
  it("deletes existing runs that match (taskId, matrixId)", () => {
    const m1: RunMeta = { ...baseMeta, runId: "run-old", signature: "d".repeat(64) };
    const m2: RunMeta = { ...baseMeta, runId: "run-newer" };
    writeRunResult(dir, m1, { prompt: "p", finalScad: "s" });
    writeRunResult(dir, m2, { prompt: "p", finalScad: "s" });

    const removed = pruneOldRuns(dir, m1.taskId, m1.matrixId);
    expect(removed.sort()).toEqual(["run-newer", "run-old"]);
    expect(existsSync(join(dir, m1.taskId, "run-old"))).toBe(false);
    expect(existsSync(join(dir, m1.taskId, "run-newer"))).toBe(false);
  });

  it("does not touch runs from other matrix entries", () => {
    const mine: RunMeta = baseMeta;
    const other: RunMeta = { ...baseMeta, runId: "other-run", matrixId: "bare/other" };
    writeRunResult(dir, mine, { prompt: "p", finalScad: "s" });
    writeRunResult(dir, other, { prompt: "p", finalScad: "s" });

    pruneOldRuns(dir, mine.taskId, mine.matrixId);
    expect(existsSync(join(dir, mine.taskId, "other-run"))).toBe(true);
    expect(existsSync(join(dir, mine.taskId, mine.runId))).toBe(false);
  });

  it("returns [] silently when the task dir is missing", () => {
    expect(pruneOldRuns(dir, "no-such-task", "bare/x")).toEqual([]);
  });
});

describe("indexResults", () => {
  it("returns an empty index when results dir is missing", () => {
    expect(indexResults(join(dir, "missing"))).toEqual({
      bySignature: new Map(),
      all: [],
    });
  });

  it("groups runs by signature across tasks", () => {
    const m1 = baseMeta;
    const m2: RunMeta = {
      ...baseMeta,
      runId: "x-run-2",
      signature: "d".repeat(64),
    };
    const m3: RunMeta = {
      ...baseMeta,
      runId: "y-run-1",
      taskId: "tier-2-mug",
      signature: "c".repeat(64),
    };
    writeRunResult(dir, m1, { prompt: "p", finalScad: "s" });
    writeRunResult(dir, m2, { prompt: "p", finalScad: "s" });
    writeRunResult(dir, m3, { prompt: "p", finalScad: "s" });

    const idx = indexResults(dir);
    expect(idx.all).toHaveLength(3);
    expect(idx.bySignature.get("c".repeat(64))?.length).toBe(2);
    expect(idx.bySignature.get("d".repeat(64))?.length).toBe(1);
  });
});
