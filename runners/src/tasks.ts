import { createHash } from "node:crypto";
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import { parse as parseYaml } from "yaml";
import { canonicalJson } from "./canonical.js";
import { type Task, TaskSchema } from "./schema.js";

export function loadTaskFile(path: string): Task {
  const raw = readFileSync(path, "utf8");
  let parsed: unknown;
  try {
    parsed = parseYaml(raw);
  } catch (e) {
    throw new Error(`failed to parse YAML at ${path}: ${(e as Error).message}`);
  }
  const result = TaskSchema.safeParse(parsed);
  if (!result.success) {
    throw new Error(
      `invalid task YAML at ${path}: ${result.error.issues
        .map((i) => `${i.path.join(".")}: ${i.message}`)
        .join("; ")}`,
    );
  }
  return result.data;
}

export function loadAllTasks(rootDir: string): Task[] {
  const tasks: Task[] = [];
  const seen = new Map<string, string>();
  for (const file of walkYamlFiles(rootDir)) {
    const task = loadTaskFile(file);
    const prev = seen.get(task.id);
    if (prev) {
      throw new Error(
        `duplicate task id "${task.id}" found in ${prev} and ${file}`,
      );
    }
    seen.set(task.id, file);
    tasks.push(task);
  }
  return tasks;
}

function* walkYamlFiles(dir: string): Generator<string> {
  let entries: string[];
  try {
    entries = readdirSync(dir);
  } catch {
    return;
  }
  for (const name of entries.sort()) {
    const full = join(dir, name);
    const st = statSync(full);
    if (st.isDirectory()) {
      yield* walkYamlFiles(full);
    } else if (st.isFile() && (name.endsWith(".yml") || name.endsWith(".yaml"))) {
      yield full;
    }
  }
}

export function computeTaskHash(task: Task): string {
  return createHash("sha256").update(canonicalJson(task)).digest("hex");
}
