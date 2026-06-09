import { describe, expect, it } from "vitest";
import { modelSupportsVision } from "./capabilities.js";

describe("modelSupportsVision", () => {
  it("accepts Claude 4.x families regardless of date suffix", () => {
    expect(modelSupportsVision("claude-opus-4-7")).toBe(true);
    expect(modelSupportsVision("claude-fable-5")).toBe(true);
    expect(modelSupportsVision("claude-sonnet-4-6")).toBe(true);
    expect(modelSupportsVision("claude-haiku-4-5-20251001")).toBe(true);
    expect(modelSupportsVision("claude-opus-4-20250514")).toBe(true);
  });

  it("accepts all Gemini 2.5 / 3.x", () => {
    expect(modelSupportsVision("gemini-3.1-pro-preview")).toBe(true);
    expect(modelSupportsVision("gemini-2.5-flash-lite")).toBe(true);
    expect(modelSupportsVision("gemini-3-flash-preview")).toBe(true);
  });

  it("accepts gpt-4.1 / gpt-5 family", () => {
    expect(modelSupportsVision("gpt-4.1-2025-04-14")).toBe(true);
    expect(modelSupportsVision("gpt-5-2025-08-07")).toBe(true);
    expect(modelSupportsVision("gpt-5-mini-2025-08-07")).toBe(true);
    expect(modelSupportsVision("gpt-5-nano-2025-08-07")).toBe(true);
    expect(modelSupportsVision("gpt-5.4-2026-03-05")).toBe(true);
    expect(modelSupportsVision("gpt-5.4-mini-2026-03-17")).toBe(true);
    expect(modelSupportsVision("gpt-5.5-2026-04-23")).toBe(true);
  });

  it("accepts gpt-5 codex family", () => {
    expect(modelSupportsVision("gpt-5-codex")).toBe(true);
    expect(modelSupportsVision("gpt-5.1-codex")).toBe(true);
    expect(modelSupportsVision("gpt-5.1-codex-max")).toBe(true);
    expect(modelSupportsVision("gpt-5.1-codex-mini")).toBe(true);
    expect(modelSupportsVision("gpt-5.2-codex")).toBe(true);
    expect(modelSupportsVision("gpt-5.3-codex")).toBe(true);
  });

  it("accepts o3 / o4-mini reasoning models", () => {
    expect(modelSupportsVision("o3-2025-04-16")).toBe(true);
    expect(modelSupportsVision("o4-mini-2025-04-16")).toBe(true);
  });

  it("rejects o1 (no vision support)", () => {
    expect(modelSupportsVision("o1")).toBe(false);
    expect(modelSupportsVision("o1-2024-12-17")).toBe(false);
  });

  it("rejects unknown / non-vision strings", () => {
    expect(modelSupportsVision("gpt-3.5-turbo")).toBe(false);
    expect(modelSupportsVision("text-davinci-003")).toBe(false);
    expect(modelSupportsVision("local-llama-7b")).toBe(false);
  });
});
