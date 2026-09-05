import type { LoadedTask } from "./results.js";
import type { ComparisonCell, ComparisonModel, ComparisonTask } from "./comparison.js";
import { compareModelsByRank, effortVariantOf, formatCost, runCostUsd, runGroupProvider, shortModelLabel, taskSlug } from "./dataset.js";

/** Keep every latest matrix result, even when only variants or failed iterations exist. */
export function buildComparisonDataset(loadedTasks: LoadedTask[]) {
  const models = new Map<string, ComparisonModel>();
  const tasks: ComparisonTask[] = loadedTasks.map(({ task, runs }) => {
    const byModel = new Map<string, ComparisonCell[]>();
    const seen = new Set<string>();
    for (const run of [...runs].sort((a, b) => b.meta.createdAt.localeCompare(a.meta.createdAt))) {
      const meta = run.meta;
      if (seen.has(meta.matrixId)) continue;
      seen.add(meta.matrixId);
      const id = meta.model ?? meta.matrixId;
      models.set(id, { id, label: shortModelLabel(id), provider: runGroupProvider(meta) });
      const head = meta.matrixId.split("/")[0]!;
      const fp = meta.fingerprint.harness;
      const iter = (fp.kind === "bare" || fp.kind === "pdf-page") && !!fp.iterateFrom;
      const effort = effortVariantOf(meta);
      let family = "other";
      let label = head;
      if (head === "bare" && !iter && meta.harness.kind === "bare") {
        family = "baseline";
        label = "単発 · 既定設定";
      } else if (head === "pdf-page" && !iter && meta.harness.kind === "pdf-page") {
        family = "baseline";
        label = "pdf-page · 既定設定";
      } else if (iter) {
        family = "iter";
        label = head.replace(/-(\d+)$/, " · $1 回目");
      } else if (head.startsWith("bare-think-")) {
        family = "thinking";
        label = `thinking · ${head.slice("bare-think-".length)}`;
      } else if (effort) {
        family = "effort";
        label = `effort · ${effort}`;
      }
      const cells = byModel.get(id) ?? [];
      // Distinct matrix configurations must not overwrite one another.
      const key = cells.some((c) => c.key === head) ? meta.matrixId : head;
      const cost = runCostUsd(meta);
      cells.push({
        key, family, label: key === head ? label : meta.matrixId,
        run: {
          href: `/run/${meta.runId}`, image: run.pngUrl, status: meta.status,
          meta: `${(meta.timing.totalMs / 1000).toFixed(1)}s${cost !== null ? " · " + formatCost(cost) : ""}`,
        },
      });
      byModel.set(id, cells);
    }
    return {
      id: task.id, title: task.title, tier: task.tier, href: `/task/${taskSlug(task)}`, prompt: task.prompt,
      models: [...byModel].map(([id, cells]) => ({ id, cells })),
    };
  });
  return { tasks, models: [...models.values()].sort((a, b) => compareModelsByRank(a.id, b.id)) };
}
