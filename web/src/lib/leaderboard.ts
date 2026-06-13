import type { RunMeta, Task } from "@vibe-openscad/runners/src/schema.js";
import type { LoadedRun } from "./results.js";
import {
  compareModelsByRank,
  runCostUsd,
  runGroupProvider,
  taskSlug,
} from "./dataset.js";

/**
 * リーダーボードの「基準軸」は **provider 既定の単発 bare run**(reasoning
 * effort や thinking を明示指定していない `bare/<model>`)。これがモデル横断で
 * 最も apples-to-apples な比較になる(DESIGN.md「素のモデル単発呼び出し」を
 * 1 級市民として扱う方針に対応)。effort variant(`bare-high/...`)、thinking
 * variant(`bare-think-off/...` のように 2 セグメント以上)、iter chain step、
 * external-agent はすべて headline 集計から除外し、深掘りは /models/<id> に委ねる。
 *
 * 判定は matrixId 先頭セグメントが **厳密に `bare`** であることで行う。
 * `bare-<...>` を正規表現で個別に弾くのではなく allow-list 的に「素の bare」
 * だけを通すので、新しい variant 命名(`bare-think-off` 等の複合セグメント)が
 * 増えても誤って baseline に混入しない。
 */
export function isBaselineRun(meta: RunMeta): boolean {
  if (meta.matrixId.split("/")[0] !== "bare") return false;
  const fp = meta.fingerprint.harness;
  return fp.kind === "bare" && !fp.iteration;
}

export interface LeaderboardTask {
  id: string;
  slug: string;
  title: string;
  tier: number;
}

export interface LeaderboardCell {
  task: LeaderboardTask;
  /** 当該 (model, task) の最新 baseline run。未実行なら null。 */
  run: LoadedRun | null;
  status: string | null;
}

export interface LeaderboardRow {
  model: string;
  /** グルーピング用の論理 provider(self-hosted は vendor 推定済み)。 */
  provider: string | null;
  /** baseline run があったタスク数。 */
  tasksAttempted: number;
  successCount: number;
  /** success / tasksAttempted。未実行なら null。 */
  successRate: number | null;
  avgLatencyMs: number | null;
  avgCostUsd: number | null;
  totalCostUsd: number | null;
  hasCost: boolean;
  /** 当該モデルの全 run 数(variant / iter / external-agent 込み)。 */
  totalRuns: number;
  /** canonical task 順に並んだセル(未実行タスクは run=null)。 */
  cells: LeaderboardCell[];
}

export interface LeaderboardData {
  /** 全 row 共通の canonical task 順(tier 昇順 → id 昇順)。 */
  tasks: LeaderboardTask[];
  rows: LeaderboardRow[];
}

/**
 * 全 run を「モデル別 × baseline 単発 bare」に畳んでリーダーボード行を作る。
 * 各行のセルは `tasks` と同じ順序に揃うので、列方向に 1 タスクをモデル横断で
 * 比較でき、行方向に 1 モデルを全タスクで見渡せる。
 */
export function buildLeaderboard(
  runs: Iterable<LoadedRun>,
  tasks: Task[],
): LeaderboardData {
  const orderedTasks: LeaderboardTask[] = [...tasks]
    .sort((a, b) => a.tier - b.tier || a.id.localeCompare(b.id))
    .map((t) => ({ id: t.id, slug: taskSlug(t), title: t.title, tier: t.tier }));

  const byModel = new Map<string, LoadedRun[]>();
  for (const r of runs) {
    const model = r.meta.model;
    if (!model) continue;
    const list = byModel.get(model) ?? [];
    list.push(r);
    byModel.set(model, list);
  }

  const rows: LeaderboardRow[] = [];
  for (const [model, modelRuns] of byModel) {
    const baselineByTask = new Map<string, LoadedRun>();
    let provider: string | null = null;
    for (const r of modelRuns) {
      if (provider === null) provider = runGroupProvider(r.meta);
      if (!isBaselineRun(r.meta)) continue;
      const cur = baselineByTask.get(r.meta.taskId);
      if (!cur || cur.meta.createdAt < r.meta.createdAt) {
        baselineByTask.set(r.meta.taskId, r);
      }
    }

    const cells: LeaderboardCell[] = orderedTasks.map((t) => {
      const run = baselineByTask.get(t.id) ?? null;
      return { task: t, run, status: run?.meta.status ?? null };
    });

    let successCount = 0;
    let latSum = 0;
    let latN = 0;
    let costSum = 0;
    let costN = 0;
    for (const run of baselineByTask.values()) {
      if (run.meta.status === "success") successCount++;
      latSum += run.meta.timing.totalMs;
      latN++;
      const c = runCostUsd(run.meta);
      if (c !== null) {
        costSum += c;
        costN++;
      }
    }
    const tasksAttempted = baselineByTask.size;

    rows.push({
      model,
      provider,
      tasksAttempted,
      successCount,
      successRate: tasksAttempted > 0 ? successCount / tasksAttempted : null,
      avgLatencyMs: latN > 0 ? latSum / latN : null,
      avgCostUsd: costN > 0 ? costSum / costN : null,
      totalCostUsd: costN > 0 ? costSum : null,
      hasCost: costN > 0,
      totalRuns: modelRuns.length,
      cells,
    });
  }

  rows.sort(compareBySuccessThenRank);
  return { tasks: orderedTasks, rows };
}

/** 既定ソート: 成功率降順 → 試行数降順 → 平均コスト昇順 → モデル順。 */
function compareBySuccessThenRank(a: LeaderboardRow, b: LeaderboardRow): number {
  const sa = a.successRate;
  const sb = b.successRate;
  if (sa === null && sb !== null) return 1;
  if (sb === null && sa !== null) return -1;
  if (sa !== null && sb !== null && sa !== sb) return sb - sa;
  if (a.tasksAttempted !== b.tasksAttempted) {
    return b.tasksAttempted - a.tasksAttempted;
  }
  const ca = a.avgCostUsd;
  const cb = b.avgCostUsd;
  if (ca !== null && cb !== null && ca !== cb) return ca - cb;
  return compareModelsByRank(a.model, b.model);
}
