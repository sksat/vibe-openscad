import { existsSync } from "node:fs";
import { join } from "node:path";
import { indexResults } from "@vibe-openscad/runners/src/results.js";
import type { RunMeta, Task } from "@vibe-openscad/runners/src/schema.js";
import { loadAllTasks } from "@vibe-openscad/runners/src/tasks.js";

export interface LoadedIteration {
  /** Index, padded directory name (e.g. "01"). */
  dir: string;
  /** URL paths into iterations/NN/ when each artifact exists. */
  scadUrl: string;
  pngUrl?: string;
  stlUrl?: string;
  noteUrl?: string;
}

export interface LoadedRun {
  meta: RunMeta;
  /** URL paths under /results/ for the static asset symlink. */
  scadUrl: string;
  pngUrl?: string;
  stlUrl?: string;
  /** Per-iteration artifacts (parallel to meta.iterations). */
  iterations: LoadedIteration[];
}

export interface LoadedTask {
  task: Task;
  /** Runs sorted newest-first. */
  runs: LoadedRun[];
}

export interface DatasetFacets {
  /** All distinct values across loaded runs, for client-side filtering UIs. */
  models: string[];
  providers: string[];
  harnessKinds: string[];
  matrixIds: string[];
  tiers: number[];
  /** Sub-agent model identifiers (e.g. for verifier sub-agents). */
  subagentModels: string[];
}

export interface LoadedDataset {
  tasks: LoadedTask[];
  /** All runs keyed by runId for quick lookup (e.g. /benchmark/[id] page). */
  runs: Map<string, LoadedRun>;
  facets: DatasetFacets;
}

export function loadDataset(repoRoot: string): LoadedDataset {
  const tasksDir = join(repoRoot, "tasks");
  const resultsDir = join(repoRoot, "results");
  const tasks = loadAllTasks(tasksDir);
  const idx = indexResults(resultsDir);

  const byTask = new Map<string, LoadedRun[]>();
  const runs = new Map<string, LoadedRun>();

  for (const meta of idx.all) {
    const runDir = join(resultsDir, meta.taskId, meta.runId);
    const urlBase = `/results/${meta.taskId}/${meta.runId}`;
    const iterations: LoadedIteration[] = [];
    for (const it of meta.iterations ?? []) {
      const dir = String(it.index).padStart(2, "0");
      const iterDir = join(runDir, "iterations", dir);
      if (!existsSync(join(iterDir, "input.scad"))) continue;
      const itBase = `${urlBase}/iterations/${dir}`;
      iterations.push({
        dir,
        scadUrl: `${itBase}/input.scad`,
        ...(existsSync(join(iterDir, "render.png"))
          ? { pngUrl: `${itBase}/render.png` }
          : {}),
        ...(existsSync(join(iterDir, "render.stl"))
          ? { stlUrl: `${itBase}/render.stl` }
          : {}),
        ...(existsSync(join(iterDir, "note.md"))
          ? { noteUrl: `${itBase}/note.md` }
          : {}),
      });
    }
    const loaded: LoadedRun = {
      meta,
      scadUrl: `${urlBase}/final.scad`,
      ...(existsSync(join(runDir, "final.png"))
        ? { pngUrl: `${urlBase}/final.png` }
        : {}),
      ...(existsSync(join(runDir, "final.stl"))
        ? { stlUrl: `${urlBase}/final.stl` }
        : {}),
      iterations,
    };
    runs.set(meta.runId, loaded);
    const list = byTask.get(meta.taskId) ?? [];
    list.push(loaded);
    byTask.set(meta.taskId, list);
  }

  for (const list of byTask.values()) {
    list.sort((a, b) => (a.meta.createdAt < b.meta.createdAt ? 1 : -1));
  }

  const loadedTasks: LoadedTask[] = tasks.map((task) => ({
    task,
    runs: byTask.get(task.id) ?? [],
  }));

  const facets = computeFacets(idx.all, tasks);

  return { tasks: loadedTasks, runs, facets };
}

function computeFacets(metas: RunMeta[], tasks: Task[]): DatasetFacets {
  const models = new Set<string>();
  const providers = new Set<string>();
  const harnessKinds = new Set<string>();
  const matrixIds = new Set<string>();
  const subagentModels = new Set<string>();
  for (const m of metas) {
    if (m.model) models.add(m.model);
    if (m.provider) providers.add(m.provider);
    harnessKinds.add(m.harness.kind);
    matrixIds.add(m.matrixId);
    if (m.harness.kind === "external-agent" && m.harness.subagents) {
      for (const sa of m.harness.subagents) subagentModels.add(sa.model);
    }
    if (m.fingerprint.harness.kind === "external-agent") {
      for (const sa of m.fingerprint.harness.subagents ?? []) {
        subagentModels.add(sa.model);
      }
    }
  }
  const tiers = Array.from(new Set(tasks.map((t) => t.tier))).sort(
    (a, b) => a - b,
  );
  return {
    models: [...models],
    providers: [...providers],
    harnessKinds: [...harnessKinds],
    matrixIds: [...matrixIds],
    tiers,
    subagentModels: [...subagentModels],
  };
}
