import { describe, expect, it } from "vitest";
import { runScheduled, type ScheduleItem } from "./scheduler.js";

/** 計測ヘルパー: in-flight 個数の最大値とアイテム完了順を捕捉する。 */
function makeProbe<T>() {
  const log: { type: "start" | "end"; key: string; bucket?: string }[] = [];
  let inflight = 0;
  let maxInflight = 0;
  const inflightByBucket = new Map<string, number>();
  const maxInflightByBucket = new Map<string, number>();
  const start = (item: ScheduleItem<T>) => {
    inflight++;
    if (inflight > maxInflight) maxInflight = inflight;
    if (item.bucket) {
      const c = (inflightByBucket.get(item.bucket) ?? 0) + 1;
      inflightByBucket.set(item.bucket, c);
      const m = maxInflightByBucket.get(item.bucket) ?? 0;
      if (c > m) maxInflightByBucket.set(item.bucket, c);
    }
    log.push({
      type: "start",
      key: item.key,
      ...(item.bucket !== undefined ? { bucket: item.bucket } : {}),
    });
  };
  const end = (item: ScheduleItem<T>) => {
    inflight--;
    if (item.bucket) {
      inflightByBucket.set(item.bucket, (inflightByBucket.get(item.bucket) ?? 1) - 1);
    }
    log.push({
      type: "end",
      key: item.key,
      ...(item.bucket !== undefined ? { bucket: item.bucket } : {}),
    });
  };
  return { log, start, end, get maxInflight() { return maxInflight; }, maxInflightByBucket };
}

describe("runScheduled", () => {
  it("runs all items even with no concurrency limit specified (default = 1)", async () => {
    const items: ScheduleItem<{}>[] = [
      { key: "a", data: {}, dependsOn: [] },
      { key: "b", data: {}, dependsOn: [] },
      { key: "c", data: {}, dependsOn: [] },
    ];
    const probe = makeProbe<{}>();
    await runScheduled(items, {}, async (it) => {
      probe.start(it);
      await new Promise((r) => setTimeout(r, 5));
      probe.end(it);
    });
    expect(probe.maxInflight).toBe(1);
    expect(probe.log.filter((l) => l.type === "end").map((l) => l.key)).toEqual([
      "a",
      "b",
      "c",
    ]);
  });

  it("respects the global concurrency cap", async () => {
    const items: ScheduleItem<{}>[] = Array.from({ length: 5 }, (_, i) => ({
      key: `k${i}`,
      data: {},
      dependsOn: [],
    }));
    const probe = makeProbe<{}>();
    await runScheduled(items, { concurrency: 3 }, async (it) => {
      probe.start(it);
      await new Promise((r) => setTimeout(r, 10));
      probe.end(it);
    });
    expect(probe.maxInflight).toBeLessThanOrEqual(3);
    expect(probe.maxInflight).toBeGreaterThanOrEqual(2);
  });

  it("respects per-bucket concurrency caps independently of the global cap", async () => {
    // 6 items, 3 in bucket A and 3 in bucket B. global=6, A cap=1, B cap=3.
    // 期待: A は 1 並列、B は 3 並列、グローバルは 4 並列まで(1+3)。
    const items: ScheduleItem<{}>[] = [
      { key: "a1", data: {}, dependsOn: [], bucket: "A" },
      { key: "a2", data: {}, dependsOn: [], bucket: "A" },
      { key: "a3", data: {}, dependsOn: [], bucket: "A" },
      { key: "b1", data: {}, dependsOn: [], bucket: "B" },
      { key: "b2", data: {}, dependsOn: [], bucket: "B" },
      { key: "b3", data: {}, dependsOn: [], bucket: "B" },
    ];
    const probe = makeProbe<{}>();
    await runScheduled(
      items,
      { concurrency: 6, perBucket: { A: 1, B: 3 } },
      async (it) => {
        probe.start(it);
        await new Promise((r) => setTimeout(r, 15));
        probe.end(it);
      },
    );
    expect(probe.maxInflightByBucket.get("A")).toBe(1);
    expect(probe.maxInflightByBucket.get("B")).toBeLessThanOrEqual(3);
    expect(probe.maxInflightByBucket.get("B")).toBeGreaterThanOrEqual(2);
  });

  it("waits for predecessors before starting an item with dependsOn", async () => {
    // a → b → c の鎖。たとえ concurrency=10 でも b は a 完了後、c は b 完了後。
    const items: ScheduleItem<{}>[] = [
      { key: "a", data: {}, dependsOn: [] },
      { key: "b", data: {}, dependsOn: ["a"] },
      { key: "c", data: {}, dependsOn: ["b"] },
    ];
    const probe = makeProbe<{}>();
    await runScheduled(items, { concurrency: 10 }, async (it) => {
      probe.start(it);
      await new Promise((r) => setTimeout(r, 10));
      probe.end(it);
    });
    // 各 start は前段の end の後に来る
    const trace = probe.log.map((l) => `${l.type}:${l.key}`);
    expect(trace.indexOf("end:a")).toBeLessThan(trace.indexOf("start:b"));
    expect(trace.indexOf("end:b")).toBeLessThan(trace.indexOf("start:c"));
    expect(probe.maxInflight).toBe(1);
  });

  it("runs independent branches in parallel under the cap", async () => {
    // a と x は独立。a→b, x→y。concurrency=4 なら a と x が並走、
    // 同様に b と y が並走できる。
    const items: ScheduleItem<{}>[] = [
      { key: "a", data: {}, dependsOn: [] },
      { key: "b", data: {}, dependsOn: ["a"] },
      { key: "x", data: {}, dependsOn: [] },
      { key: "y", data: {}, dependsOn: ["x"] },
    ];
    const probe = makeProbe<{}>();
    await runScheduled(items, { concurrency: 4 }, async (it) => {
      probe.start(it);
      await new Promise((r) => setTimeout(r, 10));
      probe.end(it);
    });
    // 一瞬は 2 並列まで上がっているはず(a と x が同時)
    expect(probe.maxInflight).toBeGreaterThanOrEqual(2);
  });

  it("propagates a runOne failure as a thrown error and still finishes other in-flight items", async () => {
    const items: ScheduleItem<{ shouldFail?: boolean }>[] = [
      { key: "a", data: {}, dependsOn: [] },
      { key: "bad", data: { shouldFail: true }, dependsOn: [] },
      { key: "c", data: {}, dependsOn: [] },
    ];
    const completed: string[] = [];
    await expect(
      runScheduled(items, { concurrency: 3 }, async (it) => {
        if (it.data.shouldFail) {
          throw new Error(`boom: ${it.key}`);
        }
        await new Promise((r) => setTimeout(r, 5));
        completed.push(it.key);
      }),
    ).rejects.toThrow(/boom: bad/);
    // 並走していた a と c は完走する(scheduler は in-flight の終わりを待つ)
    expect(completed).toContain("a");
    expect(completed).toContain("c");
  });

  it("rejects a dependsOn pointing at an unknown key (graph error)", async () => {
    const items: ScheduleItem<{}>[] = [
      { key: "a", data: {}, dependsOn: ["nonexistent"] },
    ];
    await expect(
      runScheduled(items, {}, async () => {}),
    ).rejects.toThrow(/unknown dependency/);
  });

  it("rejects a dependency cycle", async () => {
    const items: ScheduleItem<{}>[] = [
      { key: "a", data: {}, dependsOn: ["b"] },
      { key: "b", data: {}, dependsOn: ["a"] },
    ];
    await expect(
      runScheduled(items, {}, async () => {}),
    ).rejects.toThrow(/cycle/i);
  });
});
