import { describe, expect, it, vi } from "vitest";
import type { Provider } from "../providers/types.js";
import { RenderError, type RenderResult } from "../render.js";
import type { Task } from "../schema.js";
import { runBare } from "./bare.js";

const task: Task = {
  id: "tier-1-cube",
  tier: 1,
  title: "Cube",
  prompt: "Make a 50mm cube.",
};

function fakeProvider(text: string): Provider {
  return {
    name: "anthropic",
    complete: vi.fn().mockResolvedValue({
      text,
      modelId: "claude-opus-4-7",
      tokens: { input: 50, output: 25 },
      durationMs: 100,
      stopReason: "end_turn",
    }),
  };
}

const okRender = vi.fn().mockResolvedValue({
  stl: Buffer.from("STL"),
  png: Buffer.from("PNG"),
  stderr: "",
} satisfies RenderResult);

describe("runBare", () => {
  it("on success: extracts SCAD, renders, returns success result with stl/png", async () => {
    const provider = fakeProvider(
      "Here you go:\n```openscad\ncube([50,50,50]);\n```\n",
    );
    const result = await runBare({
      task,
      config: {
        kind: "bare",
        provider,
        model: "claude-opus-4-7",
      },
      render: okRender,
    });
    expect(result.status).toBe("success");
    expect(result.scad).toBe("cube([50,50,50]);");
    expect(result.stl).toBeInstanceOf(Buffer);
    expect(result.png).toBeInstanceOf(Buffer);
    expect(result.tokens).toEqual({ input: 50, output: 25 });
    expect(result.modelId).toBe("claude-opus-4-7");
    expect(result.harnessLog).toEqual({ kind: "bare" });
  });

  it("calls the provider with the task prompt and configured model", async () => {
    const provider = fakeProvider("```openscad\ncube();\n```");
    await runBare({
      task,
      config: {
        kind: "bare",
        provider,
        model: "claude-opus-4-7",
        systemPrompt: "You are an OpenSCAD expert.",
        maxTokens: 4096,
      },
      render: okRender,
    });
    expect(provider.complete).toHaveBeenCalledWith({
      prompt: task.prompt,
      model: "claude-opus-4-7",
      systemPrompt: "You are an OpenSCAD expert.",
      maxTokens: 4096,
    });
  });

  it("returns no_code when response has no SCAD code block", async () => {
    const provider = fakeProvider("Sorry, I cannot help.");
    const result = await runBare({
      task,
      config: { kind: "bare", provider, model: "m" },
      render: okRender,
    });
    expect(result.status).toBe("no_code");
    expect(result.scad).toBeUndefined();
    expect(result.errorMessage).toBeDefined();
  });

  it("returns render_error and preserves the SCAD when render throws", async () => {
    const provider = fakeProvider("```openscad\ninvalid\n```");
    const render = vi
      .fn()
      .mockRejectedValue(new RenderError("stl", 2, "syntax error"));
    const result = await runBare({
      task,
      config: { kind: "bare", provider, model: "m" },
      render,
    });
    expect(result.status).toBe("render_error");
    expect(result.scad).toBe("invalid");
    expect(result.errorMessage).toContain("syntax error");
  });

  it("returns api_error when provider throws", async () => {
    const provider: Provider = {
      name: "anthropic",
      complete: vi.fn().mockRejectedValue(new Error("rate limited")),
    };
    const result = await runBare({
      task,
      config: { kind: "bare", provider, model: "m" },
      render: okRender,
    });
    expect(result.status).toBe("api_error");
    expect(result.errorMessage).toContain("rate limited");
  });
});
