import { readFileSync } from "node:fs";
import { parse as parseYaml } from "yaml";
import {
  type BenchConfig,
  BenchConfigSchema,
  type MatrixEntry,
  type Task,
} from "./schema.js";

export function loadBenchConfig(path: string): BenchConfig {
  const raw = readFileSync(path, "utf8");
  let parsed: unknown;
  try {
    parsed = parseYaml(raw);
  } catch (e) {
    throw new Error(`failed to parse YAML at ${path}: ${(e as Error).message}`);
  }
  const result = BenchConfigSchema.safeParse(parsed);
  if (!result.success) {
    throw new Error(
      `invalid bench config at ${path}: ${result.error.issues
        .map((i) => `${i.path.join(".")}: ${i.message}`)
        .join("; ")}`,
    );
  }
  return result.data;
}

export interface Candidate {
  task: Task;
  entry: MatrixEntry;
}

export function expandMatrix(cfg: BenchConfig, tasks: Task[]): Candidate[] {
  const tasksById = new Map(tasks.map((t) => [t.id, t]));

  const selectedTasks: Task[] = [];
  const seenTaskIds = new Set<string>();
  for (const sel of cfg.tasks) {
    if ("id" in sel) {
      const t = tasksById.get(sel.id);
      if (!t) {
        throw new Error(
          `bench-config tasks references missing task id: ${sel.id}`,
        );
      }
      if (!seenTaskIds.has(t.id)) {
        seenTaskIds.add(t.id);
        selectedTasks.push(t);
      }
    } else {
      const matched = tasks.filter((t) => t.tier === sel.tier);
      if (matched.length === 0) {
        throw new Error(
          `bench-config tasks: tier ${sel.tier} matched no tasks`,
        );
      }
      for (const t of matched) {
        if (!seenTaskIds.has(t.id)) {
          seenTaskIds.add(t.id);
          selectedTasks.push(t);
        }
      }
    }
  }

  const candidates: Candidate[] = [];
  for (const entry of cfg.matrix) {
    for (const task of selectedTasks) {
      candidates.push({ entry, task });
    }
  }
  return candidates;
}
