/**
 * 並列実行用のシンプルなスケジューラ。
 *
 * 設計指針:
 * - 並列度の制約を 2 軸で持つ: グローバル上限と「bucket(provider 等)」毎の
 *   上限。provider 別 rate limit を尊重するため。
 * - DAG 依存(`dependsOn`)を持つ。iteration chain の child は parent 完了を
 *   待たないと parent 出力(SCAD/PNG)を読めないため。
 * - runOne の中で何が起きるかには関与しない(provider 呼び出し / I/O は
 *   呼び出し側責任)。スケジューラは「いつ走らせるか」だけ。
 * - 1 つでも runOne が throw したら、in-flight を完走させたうえで集約 throw。
 *   途中失敗でも他のレーンは止めない方が、benchmark 用途では情報が多い。
 */

export interface ScheduleItem<T = unknown> {
  /** ユニーク key。`dependsOn` から参照される ID。 */
  key: string;
  /** runOne に渡される payload(item の中身は scheduler は触らない)。 */
  data: T;
  /** この item が走り始めるために完了している必要がある predecessor key 群。
   *  完了とは「runOne の Promise が resolve した」ことを指す(reject の場合は
   *  child は走らせない、キャンセル扱い)。 */
  dependsOn: string[];
  /** 並列上限を別軸で課したいときの bucket(例: "anthropic", "openai")。
   *  未指定なら bucket 制約を受けない。 */
  bucket?: string;
}

export interface ScheduleOptions {
  /** 同時実行できる最大数。default=1(直列)。 */
  concurrency?: number;
  /** bucket 別の同時実行上限。bucket が perBucket に無ければ Infinity。 */
  perBucket?: Record<string, number>;
}

interface InternalNode<T> {
  item: ScheduleItem<T>;
  remaining: number;
  /** false: まだ走らせていない / true: 走らせ始めた(または完了/失敗)。 */
  started: boolean;
  /** runOne が成功して終わった場合 true。失敗した場合は false。 */
  succeeded?: boolean;
}

export async function runScheduled<T>(
  items: ScheduleItem<T>[],
  options: ScheduleOptions,
  runOne: (item: ScheduleItem<T>) => Promise<void>,
): Promise<void> {
  const concurrency = Math.max(1, options.concurrency ?? 1);
  const perBucket = options.perBucket ?? {};

  // ノード化 + 依存検証。
  const nodes = new Map<string, InternalNode<T>>();
  for (const it of items) {
    if (nodes.has(it.key)) {
      throw new Error(`duplicate scheduler key: ${it.key}`);
    }
    nodes.set(it.key, { item: it, remaining: it.dependsOn.length, started: false });
  }
  // 不明な依存先を検出 + 「依存先が誰の predecessor か」を逆引き化。
  const dependents = new Map<string, string[]>();
  for (const it of items) {
    for (const dep of it.dependsOn) {
      if (!nodes.has(dep)) {
        throw new Error(
          `unknown dependency: "${it.key}" depends on "${dep}" which is not in the item set`,
        );
      }
      const list = dependents.get(dep) ?? [];
      list.push(it.key);
      dependents.set(dep, list);
    }
  }
  detectCycle(items);

  const inflightByBucket = new Map<string, number>();
  let inflight = 0;
  const errors: unknown[] = [];

  // 「次に走らせられるもの」を選ぶ。bucket cap は厳格、ただし他に走るものが
  // 無いと永久待ちになるので bucket cap に引っかかった item はスキップして
  // 別のものを試す(deadlock 回避のため)。
  function pickReady(): InternalNode<T> | null {
    for (const node of nodes.values()) {
      if (node.started) continue;
      if (node.remaining > 0) continue;
      const b = node.item.bucket;
      if (b !== undefined) {
        const cap = perBucket[b] ?? Infinity;
        const cur = inflightByBucket.get(b) ?? 0;
        if (cur >= cap) continue;
      }
      return node;
    }
    return null;
  }

  return new Promise<void>((resolve, reject) => {
    function tryDispatch(): void {
      // 余地がある限り pickReady を回す。
      while (inflight < concurrency) {
        const node = pickReady();
        if (!node) break;
        node.started = true;
        inflight++;
        const b = node.item.bucket;
        if (b !== undefined) {
          inflightByBucket.set(b, (inflightByBucket.get(b) ?? 0) + 1);
        }
        runOne(node.item).then(
          () => onFinish(node, true),
          (err: unknown) => {
            errors.push(err);
            onFinish(node, false);
          },
        );
      }
      // 何も走っていない && 何も pick できないなら終了 or デッドロック判定。
      if (inflight === 0) {
        const remaining = [...nodes.values()].filter((n) => !n.started);
        if (remaining.length === 0) {
          if (errors.length > 0) {
            reject(aggregateError(errors));
          } else {
            resolve();
          }
        } else {
          // ここに来る = 依存が満たされていないのに親が失敗等で
          // 永久に解放されないケース。失敗扱いで止める。
          if (errors.length > 0) {
            reject(aggregateError(errors));
          } else {
            reject(
              new Error(
                `scheduler stalled with ${remaining.length} item(s) unable to run; check dependsOn`,
              ),
            );
          }
        }
      }
    }
    function onFinish(node: InternalNode<T>, ok: boolean): void {
      inflight--;
      const b = node.item.bucket;
      if (b !== undefined) {
        inflightByBucket.set(b, (inflightByBucket.get(b) ?? 1) - 1);
      }
      node.succeeded = ok;
      if (ok) {
        const children = dependents.get(node.item.key) ?? [];
        for (const childKey of children) {
          const child = nodes.get(childKey)!;
          child.remaining--;
        }
      } else {
        // 失敗したら子は走らせない(scheduler stall を避けるため、
        // 子も "started=true" でマーク。errors には親の理由が既に積まれている)。
        markDescendantsAsBlocked(node.item.key, dependents, nodes);
      }
      tryDispatch();
    }
    tryDispatch();
  });
}

function markDescendantsAsBlocked<T>(
  key: string,
  dependents: Map<string, string[]>,
  nodes: Map<string, InternalNode<T>>,
): void {
  const stack = [...(dependents.get(key) ?? [])];
  while (stack.length > 0) {
    const k = stack.pop()!;
    const node = nodes.get(k);
    if (!node || node.started) continue;
    node.started = true; // never run
    for (const grand of dependents.get(k) ?? []) stack.push(grand);
  }
}

function aggregateError(errors: unknown[]): Error {
  if (errors.length === 1) {
    const e = errors[0];
    if (e instanceof Error) return e;
    return new Error(String(e));
  }
  const msg = errors
    .map((e) => (e instanceof Error ? e.message : String(e)))
    .join("\n");
  return new Error(`scheduler caught ${errors.length} error(s):\n${msg}`);
}

function detectCycle<T>(items: ScheduleItem<T>[]): void {
  const adj = new Map<string, string[]>();
  for (const it of items) adj.set(it.key, it.dependsOn);
  const WHITE = 0, GRAY = 1, BLACK = 2;
  const color = new Map<string, number>();
  for (const k of adj.keys()) color.set(k, WHITE);
  function dfs(u: string, path: string[]): void {
    color.set(u, GRAY);
    for (const v of adj.get(u) ?? []) {
      const c = color.get(v);
      if (c === GRAY) {
        throw new Error(
          `dependency cycle detected: ${[...path, u, v].join(" → ")}`,
        );
      }
      if (c === WHITE) dfs(v, [...path, u]);
    }
    color.set(u, BLACK);
  }
  for (const k of adj.keys()) {
    if (color.get(k) === WHITE) dfs(k, []);
  }
}
