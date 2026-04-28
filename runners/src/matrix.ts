import { readFileSync } from "node:fs";
import { parse as parseYaml } from "yaml";
import { modelSupportsVision } from "./capabilities.js";
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
      // vision タスク × vision 非対応モデルの組み合わせは plan 段階で除外。
      // プロバイダ API が画像入力を拒否して必ず api_error になるだけ
      // (= 課金の無駄)なので、候補集合に入れない方がノイズが減る。
      if (
        task.prompt_images &&
        task.prompt_images.length > 0 &&
        entry.harness.kind === "bare" &&
        "model" in entry &&
        !modelSupportsVision(entry.model)
      ) {
        continue;
      }
      // pdf_source を持つ task は pdf-page harness 専用。それ以外の harness
      // (bare / iter-png chain / external-agent)が紛れ込むと、PDF を読まずに
      // text プロンプトだけで走って混乱の元になる。
      if (task.pdf_source && entry.harness.kind !== "pdf-page") {
        continue;
      }
      // 逆に pdf-page harness × pdf_source なし task も意味が無いので除外。
      if (entry.harness.kind === "pdf-page" && !task.pdf_source) {
        continue;
      }
      // pdf-page でも provider 側 vision 非対応モデルなら撥ねる。
      if (
        entry.harness.kind === "pdf-page" &&
        "model" in entry &&
        !modelSupportsVision(entry.model)
      ) {
        continue;
      }
      candidates.push({ entry, task });
    }
  }
  return candidates;
}
