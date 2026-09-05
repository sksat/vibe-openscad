import { describe, expect, it } from "vitest";
import {
  BenchConfigSchema,
  FingerprintSchema,
  RunMetaSchema,
  TaskSchema,
} from "./schema.js";

describe("TaskSchema", () => {
  it("accepts a valid task", () => {
    const task = {
      id: "tier-1-cube-with-hole",
      tier: 1,
      title: "Cube with through hole",
      prompt: "Make a 50mm cube with a 20mm hole.",
    };
    expect(TaskSchema.parse(task)).toEqual(task);
  });

  it("requires id, tier, title, prompt", () => {
    expect(() => TaskSchema.parse({ tier: 1, title: "x", prompt: "y" })).toThrow();
    expect(() => TaskSchema.parse({ id: "x", title: "x", prompt: "y" })).toThrow();
    expect(() => TaskSchema.parse({ id: "x", tier: 1, prompt: "y" })).toThrow();
    expect(() => TaskSchema.parse({ id: "x", tier: 1, title: "x" })).toThrow();
  });

  it("rejects non-positive tier", () => {
    expect(() =>
      TaskSchema.parse({ id: "x", tier: 0, title: "t", prompt: "p" }),
    ).toThrow();
    expect(() =>
      TaskSchema.parse({ id: "x", tier: -1, title: "t", prompt: "p" }),
    ).toThrow();
  });
});

describe("BenchConfigSchema", () => {
  it("accepts a config with bare and external-agent matrix entries", () => {
    const cfg = {
      defaults: { samples: 1, timeoutSec: 300 },
      matrix: [
        {
          id: "claude-opus-bare",
          harness: { kind: "bare" },
          provider: "anthropic",
          model: "claude-opus-4-7",
        },
        {
          id: "claude-opus-cc",
          harness: { kind: "external-agent", agent: "claude-code", maxTurns: 8 },
        },
      ],
      tasks: [{ tier: 1 }, { id: "tier-2-gear" }],
    };
    expect(BenchConfigSchema.parse(cfg)).toBeTruthy();
  });

  it("requires provider+model when harness kind is bare", () => {
    expect(() =>
      BenchConfigSchema.parse({
        matrix: [{ id: "x", harness: { kind: "bare" } }],
        tasks: [{ tier: 1 }],
      }),
    ).toThrow();
  });

  it("requires agent+maxTurns when harness kind is external-agent", () => {
    expect(() =>
      BenchConfigSchema.parse({
        matrix: [
          { id: "x", harness: { kind: "external-agent", agent: "claude-code" } },
        ],
        tasks: [{ tier: 1 }],
      }),
    ).toThrow();
  });

  it("rejects duplicate matrix ids", () => {
    expect(() =>
      BenchConfigSchema.parse({
        matrix: [
          { id: "dup", harness: { kind: "bare" }, provider: "x", model: "y" },
          { id: "dup", harness: { kind: "bare" }, provider: "x", model: "z" },
        ],
        tasks: [{ tier: 1 }],
      }),
    ).toThrow();
  });

  it("applies default samples=1 and timeoutSec=300", () => {
    const cfg = BenchConfigSchema.parse({
      matrix: [
        {
          id: "x",
          harness: { kind: "bare" },
          provider: "anthropic",
          model: "m",
        },
      ],
      tasks: [{ tier: 1 }],
    });
    expect(cfg.defaults.samples).toBe(1);
    expect(cfg.defaults.timeoutSec).toBe(300);
  });
});

describe("FingerprintSchema", () => {
  it("accepts a bare fingerprint", () => {
    const fp = {
      schemaVersion: 1,
      taskHash: "a".repeat(64),
      harness: {
        kind: "bare",
        provider: "anthropic",
        model: "claude-opus-4-7",
      },
      openscadVersion: "OpenSCAD 2021.01",
      promptTemplateHash: "b".repeat(64),
    };
    expect(FingerprintSchema.parse(fp)).toBeTruthy();
  });

  it("accepts an external-agent fingerprint with allowedTools", () => {
    const fp = {
      schemaVersion: 1,
      taskHash: "a".repeat(64),
      harness: {
        kind: "external-agent",
        agent: "claude-code",
        agentVersion: "0.5.0",
        maxTurns: 8,
        allowedTools: ["mcp__bench__render_openscad", "mcp__bench__submit_final"],
      },
      mcpServerVersion: "0.0.1",
      openscadVersion: "OpenSCAD 2021.01",
      promptTemplateHash: "b".repeat(64),
    };
    expect(FingerprintSchema.parse(fp)).toBeTruthy();
  });

  it("accepts an external-agent fingerprint with subagents", () => {
    const fp = {
      schemaVersion: 1,
      taskHash: "a".repeat(64),
      harness: {
        kind: "external-agent",
        agent: "claude-code",
        agentVersion: "0.5.0",
        maxTurns: 8,
        allowedTools: ["mcp__bench__render_openscad"],
        subagents: [
          {
            name: "render-verifier",
            provider: "anthropic",
            model: "claude-haiku-4-5",
            role: "review_render",
          },
        ],
      },
      openscadVersion: "OpenSCAD 2021.01",
      promptTemplateHash: "b".repeat(64),
    };
    expect(FingerprintSchema.parse(fp)).toBeTruthy();
  });

  it("rejects unknown harness kinds", () => {
    expect(() =>
      FingerprintSchema.parse({
        schemaVersion: 1,
        taskHash: "a".repeat(64),
        harness: { kind: "wat" },
        openscadVersion: "x",
        promptTemplateHash: "b".repeat(64),
      }),
    ).toThrow();
  });
});

describe("RunMetaSchema", () => {
  const baseFingerprint = {
    schemaVersion: 1,
    taskHash: "a".repeat(64),
    harness: { kind: "bare", provider: "anthropic", model: "m" },
    openscadVersion: "x",
    promptTemplateHash: "b".repeat(64),
  };

  it("accepts a successful bare run", () => {
    const meta = {
      runId: "claude-opus-bare-abc123-2026-04-27T00-00-00Z",
      taskId: "tier-1-cube-with-hole",
      matrixId: "claude-opus-bare",
      signature: "c".repeat(64),
      fingerprint: baseFingerprint,
      provider: "anthropic",
      model: "claude-opus-4-7",
      harness: { kind: "bare" },
      status: "success",
      timing: { totalMs: 1234 },
      createdAt: "2026-04-27T00:00:00Z",
    };
    expect(RunMetaSchema.parse(meta)).toBeTruthy();
  });

  it("records the model id the API reported, separately from the configured one", () => {
    // alias で送っても provider が dated snapshot を返すことがある。設定値
    // (model)と実際に応答した id(resolvedModel)は別物として残す。
    const meta = {
      runId: "r",
      taskId: "t",
      matrixId: "bare/m",
      signature: "c".repeat(64),
      fingerprint: baseFingerprint,
      provider: "openai",
      model: "gpt-5.4",
      resolvedModel: "gpt-5.4-2026-03-05",
      harness: { kind: "bare" },
      status: "success",
      timing: { totalMs: 1 },
      createdAt: "2026-04-27T00:00:00Z",
    };
    expect(RunMetaSchema.parse(meta).resolvedModel).toBe("gpt-5.4-2026-03-05");
  });

  it("rejects unknown status", () => {
    expect(() =>
      RunMetaSchema.parse({
        runId: "x",
        taskId: "x",
        matrixId: "x",
        signature: "c".repeat(64),
        fingerprint: baseFingerprint,
        provider: "anthropic",
        model: "m",
        harness: { kind: "bare" },
        status: "weird",
        timing: { totalMs: 1 },
        createdAt: "2026-04-27T00:00:00Z",
      }),
    ).toThrow();
  });
});
