import { describe, expect, it } from "vitest";
import type { RunMeta } from "@vibe-openscad/runners/src/schema.js";
import type { LoadedRun, LoadedTask } from "./results.js";
import { buildComparisonDataset } from "./comparison-data.js";

function run(matrixId: string, createdAt = "2026-01-01", status: RunMeta["status"] = "success"): LoadedRun {
  return {
    scadUrl: "/final.scad",
    meta: {
      runId: `${matrixId}-${createdAt}`, taskId: "cube", matrixId, createdAt,
      signature: "s", model: "gpt-5", provider: "openai", harness: { kind: "bare" },
      fingerprint: { schemaVersion: 1, taskHash: "t", promptTemplateHash: "p", openscadVersion: "v", harness: { kind: "bare", provider: "openai", model: "gpt-5" } },
      status, timing: { totalMs: 1000 },
    },
  };
}
const task = (runs: LoadedRun[]): LoadedTask => ({ task: { id: "cube", title: "Cube", tier: 1, prompt: "cube" }, runs });

describe("comparison dataset", () => {
  it("shows the default PDF-page result as a primary row rather than a collapsed variant", () => {
    const pdf = run("pdf-page/gpt-5");
    pdf.meta.harness = { kind: "pdf-page" };
    pdf.meta.fingerprint.harness = { kind: "pdf-page", provider: "openai", model: "gpt-5" };
    const cell = buildComparisonDataset([task([pdf])]).tasks[0]!.models[0]!.cells[0]!;
    expect(cell.family).toBe("baseline");
    expect(cell.key).toBe("pdf-page");
    expect(cell.label).toBe("pdf-page · 既定設定");
  });
  it("uses latest run per matrix, including latest failures, and preserves variants without a baseline", () => {
    const ds = buildComparisonDataset([task([run("bare-low/gpt-5"), run("bare-low/gpt-5", "2026-02-01", "render_error"), run("bare-think-off/gpt-5")])]);
    const cells = ds.tasks[0]!.models[0]!.cells;
    expect(cells).toHaveLength(2);
    expect(cells.find((c) => c.family === "effort")!.run.status).toBe("render_error");
    expect(cells.some((c) => c.family === "baseline")).toBe(false);
    expect(cells.some((c) => c.family === "thinking")).toBe(true);
  });
  it("does not drop an iteration whose parent run is unavailable", () => {
    const iter = run("iter-png-2/gpt-5");
    iter.meta.fingerprint.harness = { kind: "bare", provider: "openai", model: "gpt-5", iterateFrom: "iter-png-1/gpt-5", iteration: { kind: "render-png-feedback" } };
    const cell = buildComparisonDataset([task([iter])]).tasks[0]!.models[0]!.cells[0]!;
    expect(cell.family).toBe("iter");
    expect(cell.label).toContain("2");
  });
});
