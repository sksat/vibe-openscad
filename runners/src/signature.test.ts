import { describe, expect, it } from "vitest";
import type { Fingerprint } from "./schema.js";
import { computeSignature, shortSignature } from "./signature.js";

const baseBare: Fingerprint = {
  schemaVersion: 1,
  taskHash: "a".repeat(64),
  harness: { kind: "bare", provider: "anthropic", model: "claude-opus-4-7" },
  openscadVersion: "OpenSCAD 2021.01",
  promptTemplateHash: "b".repeat(64),
};

describe("computeSignature", () => {
  it("returns 64-char hex sha256", () => {
    expect(computeSignature(baseBare)).toMatch(/^[0-9a-f]{64}$/);
  });

  it("is deterministic across calls", () => {
    expect(computeSignature(baseBare)).toBe(computeSignature(baseBare));
  });

  it("does not depend on key declaration order", () => {
    const a = computeSignature(baseBare);
    const reordered: Fingerprint = {
      promptTemplateHash: baseBare.promptTemplateHash,
      taskHash: baseBare.taskHash,
      schemaVersion: baseBare.schemaVersion,
      openscadVersion: baseBare.openscadVersion,
      harness: {
        model: "claude-opus-4-7",
        provider: "anthropic",
        kind: "bare",
      } as never,
    };
    expect(computeSignature(reordered)).toBe(a);
  });

  it("changes when any single field changes", () => {
    const fields: Array<(fp: Fingerprint) => Fingerprint> = [
      (fp) => ({ ...fp, taskHash: "c".repeat(64) }),
      (fp) => ({ ...fp, openscadVersion: "OpenSCAD 2024.04" }),
      (fp) => ({ ...fp, promptTemplateHash: "d".repeat(64) }),
      (fp) => ({
        ...fp,
        harness: { ...(fp.harness as { kind: "bare" } & Record<string, unknown>), model: "claude-haiku-4-5" } as never,
      }),
    ];
    const base = computeSignature(baseBare);
    for (const mutate of fields) {
      expect(computeSignature(mutate(baseBare))).not.toBe(base);
    }
  });

  it("distinguishes bare and external-agent harnesses", () => {
    const ea: Fingerprint = {
      schemaVersion: 1,
      taskHash: baseBare.taskHash,
      harness: {
        kind: "external-agent",
        agent: "claude-code",
        agentVersion: "0.5.0",
        maxTurns: 8,
        allowedTools: ["mcp__bench__render_openscad", "mcp__bench__submit_final"],
      },
      openscadVersion: baseBare.openscadVersion,
      promptTemplateHash: baseBare.promptTemplateHash,
    };
    expect(computeSignature(ea)).not.toBe(computeSignature(baseBare));
  });

  it("changes when a subagent's model changes", () => {
    const make = (subagentModel: string): Fingerprint => ({
      schemaVersion: 1,
      taskHash: baseBare.taskHash,
      harness: {
        kind: "external-agent",
        agent: "claude-code",
        agentVersion: "0.5.0",
        maxTurns: 8,
        allowedTools: ["mcp__bench__render_openscad"],
        subagents: [
          {
            name: "verifier",
            provider: "anthropic",
            model: subagentModel,
            role: "review_render",
          },
        ],
      },
      openscadVersion: baseBare.openscadVersion,
      promptTemplateHash: baseBare.promptTemplateHash,
    });
    expect(computeSignature(make("claude-haiku-4-5"))).not.toBe(
      computeSignature(make("claude-haiku-3-5")),
    );
  });

  it("subagent order matters for the signature", () => {
    const sub = (name: string, model: string) => ({
      name,
      provider: "anthropic",
      model,
    });
    const make = (subagents: Array<{ name: string; model: string }>): Fingerprint => ({
      schemaVersion: 1,
      taskHash: baseBare.taskHash,
      harness: {
        kind: "external-agent",
        agent: "claude-code",
        agentVersion: "0.5.0",
        maxTurns: 8,
        allowedTools: [],
        subagents: subagents.map((s) => sub(s.name, s.model)),
      },
      openscadVersion: baseBare.openscadVersion,
      promptTemplateHash: baseBare.promptTemplateHash,
    });
    const a = computeSignature(make([{ name: "a", model: "m1" }, { name: "b", model: "m2" }]));
    const b = computeSignature(make([{ name: "b", model: "m2" }, { name: "a", model: "m1" }]));
    expect(a).not.toBe(b);
  });

  it("treats different allowedTools order as the same signature", () => {
    const make = (tools: string[]): Fingerprint => ({
      schemaVersion: 1,
      taskHash: baseBare.taskHash,
      harness: {
        kind: "external-agent",
        agent: "claude-code",
        agentVersion: "0.5.0",
        maxTurns: 8,
        allowedTools: tools,
      },
      openscadVersion: baseBare.openscadVersion,
      promptTemplateHash: baseBare.promptTemplateHash,
    });
    const a = computeSignature(make(["a", "b"]));
    const b = computeSignature(make(["b", "a"]));
    expect(a).toBe(b);
  });
});

describe("shortSignature", () => {
  it("returns first 12 chars of signature", () => {
    const sig = "0".repeat(60) + "abcdef";
    expect(shortSignature(sig)).toBe("0".repeat(12));
    expect(shortSignature("c".repeat(64))).toHaveLength(12);
  });
});
