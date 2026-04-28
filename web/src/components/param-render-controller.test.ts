import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { createParamRenderController } from "./param-render-controller.js";

describe("param render controller", () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });
  afterEach(() => {
    vi.useRealTimers();
  });

  it("renders once after the debounce expires", async () => {
    const render = vi.fn().mockResolvedValue("STL");
    const setStatus = vi.fn();
    const applyResult = vi.fn();
    const c = createParamRenderController({
      buildSource: () => "scad",
      render,
      applyResult,
      setStatus,
      debounceMs: 80,
    });
    c.scheduleRerender();
    expect(render).not.toHaveBeenCalled();
    await vi.advanceTimersByTimeAsync(100);
    expect(render).toHaveBeenCalledTimes(1);
    expect(applyResult).toHaveBeenCalledWith("STL");
    expect(setStatus).toHaveBeenLastCalledWith("ready");
  });

  it("collapses bursts of rapid reschedules into one render with the latest source", async () => {
    let v = 0;
    const render = vi.fn().mockResolvedValue("STL");
    const c = createParamRenderController({
      buildSource: () => `v${v}`,
      render,
      applyResult: () => {},
      setStatus: () => {},
      debounceMs: 80,
    });
    v = 1;
    c.scheduleRerender();
    v = 2;
    c.scheduleRerender();
    v = 3;
    c.scheduleRerender();
    await vi.advanceTimersByTimeAsync(100);
    expect(render).toHaveBeenCalledTimes(1);
    expect(render).toHaveBeenCalledWith("v3");
  });

  it("on render failure, sets error status with the error message", async () => {
    const render = vi.fn().mockRejectedValue(new Error("ERROR: bad token"));
    const setStatus = vi.fn();
    const c = createParamRenderController({
      buildSource: () => "scad",
      render,
      applyResult: () => {},
      setStatus,
      debounceMs: 80,
    });
    c.scheduleRerender();
    await vi.advanceTimersByTimeAsync(100);
    await vi.runAllTimersAsync();
    expect(setStatus).toHaveBeenLastCalledWith("error: ERROR: bad token", true);
  });

  it("retries with the latest source after a failure if a follow-up was queued mid-flight, and clears the error if the retry succeeds", async () => {
    // ★ reset 直後の挙動を再現するテスト。
    //
    // 1. スライダーで不正値 → render 1 が走り始める(まだ resolve しない)
    // 2. ユーザが reset → param が default に戻り scheduleRerender される
    //    が、render 1 がまだ in-flight なので pendingDirty=true だけ立つ
    // 3. render 1 が reject(エラー) → 旧実装ではここで error pill を出して
    //    drive ループが終了してしまい、pendingDirty 分の retry が走らない
    // 4. 期待: pendingDirty を消化して render 2(default 値)を実行 →
    //    成功なら "ready" になり、error pill は残らない
    let resolveR1!: (v: string) => void;
    let rejectR1!: (e: Error) => void;
    const render = vi
      .fn<(src: string) => Promise<string>>()
      .mockImplementationOnce(
        () =>
          new Promise<string>((res, rej) => {
            resolveR1 = res;
            rejectR1 = rej;
          }),
      )
      .mockResolvedValue("STL_OK");
    const setStatus = vi.fn();
    const applyResult = vi.fn();
    let src = "bad";
    const c = createParamRenderController({
      buildSource: () => src,
      render,
      applyResult,
      setStatus,
      debounceMs: 80,
    });
    // step 1: 1 回目 schedule、debounce 経過、render 1 in-flight
    c.scheduleRerender();
    await vi.advanceTimersByTimeAsync(100);
    expect(render).toHaveBeenCalledTimes(1);
    expect(render).toHaveBeenLastCalledWith("bad");

    // step 2: reset 相当。source を default に戻して再 schedule
    src = "default";
    c.scheduleRerender();
    // pendingDirty が立つ debounce を進める
    await vi.advanceTimersByTimeAsync(100);
    // この時点で render はまだ 1 回(in-flight 中だったので追加で呼ばれて
    // いない)
    expect(render).toHaveBeenCalledTimes(1);

    // step 3: render 1 が失敗
    rejectR1(new Error("bad value"));
    await vi.runAllTimersAsync();

    // 期待: render 2 (default) が走り、最終 status は ready
    expect(render).toHaveBeenCalledTimes(2);
    expect(render).toHaveBeenLastCalledWith("default");
    expect(applyResult).toHaveBeenCalledWith("STL_OK");
    expect(setStatus).toHaveBeenLastCalledWith("ready");
    // resolveR1 は使わない(rejectR1 で先にエラーにする)
    void resolveR1;
  });

  it("if both the in-flight render and the queued retry fail, leaves the latest error on the status pill", async () => {
    let resolveR1!: (v: string) => void;
    let rejectR1!: (e: Error) => void;
    const render = vi
      .fn<(src: string) => Promise<string>>()
      .mockImplementationOnce(
        () =>
          new Promise<string>((res, rej) => {
            resolveR1 = res;
            rejectR1 = rej;
          }),
      )
      .mockRejectedValue(new Error("still broken"));
    const setStatus = vi.fn();
    const c = createParamRenderController({
      buildSource: () => "scad",
      render,
      applyResult: () => {},
      setStatus,
      debounceMs: 80,
    });
    c.scheduleRerender();
    await vi.advanceTimersByTimeAsync(100);
    c.scheduleRerender();
    await vi.advanceTimersByTimeAsync(100);
    rejectR1(new Error("first failure"));
    await vi.runAllTimersAsync();
    expect(render).toHaveBeenCalledTimes(2);
    expect(setStatus).toHaveBeenLastCalledWith("error: still broken", true);
    void resolveR1;
  });
});
