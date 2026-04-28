/**
 * スライダー入力 → wasm レンダ呼び出しのスケジューラ。
 *
 * - 連続入力は debounce で 1 回にまとめる。
 * - レンダリングは 1 つずつ直列に走る(worker 内の wasm callMain が
 *   /input.scad を共有しているため、並走させると競合する)。
 * - 1 つ走っている間に来た要求は最後の値だけ覚えて、現在のレンダが
 *   終わったら追加で 1 回走らせる(最新値を 1 つだけキューに保持)。
 * - レンダ中にエラーが出ても、キューに次のがあれば retry してから
 *   ステータスを最終決定する(例: スライダーで一瞬不正値 → 直後に
 *   reset で正値に戻したケースで、エラー pill が残ってしまわない)。
 */
export interface ParamRenderControllerOptions {
  /** SCAD source を生成する関数。drive 開始時の最新値で 1 度呼ばれる。 */
  buildSource: () => string;
  /** wasm に投げて STL を返してもらう。reject されると error 扱い。 */
  render: (source: string) => Promise<string>;
  /** 受け取った STL を 3D シーンに反映する側。 */
  applyResult: (stl: string) => void;
  /** ステータス pill の更新。第二引数 true でエラー色。 */
  setStatus: (text: string, error?: boolean) => void;
  /** input 連打を吸収する debounce 時間。Default 80ms. */
  debounceMs?: number;
}

export interface ParamRenderController {
  /** スライダーが動いた等で再 render を予約する。 */
  scheduleRerender(): void;
}

export function createParamRenderController(
  opts: ParamRenderControllerOptions,
): ParamRenderController {
  const debounceMs = opts.debounceMs ?? 80;
  let isRendering = false;
  let pendingDirty = false;
  let scheduledTimer: ReturnType<typeof setTimeout> | null = null;

  const drive = async (): Promise<void> => {
    if (isRendering) {
      // 既に走っている render が終わったあと、最新値で 1 回追加で走らせる。
      pendingDirty = true;
      return;
    }
    isRendering = true;
    // ループ最後の試行の結果(成功なら null、失敗なら error 文字列)。
    // ループ全体が終わってから「error pill か ready か」を 1 回だけ
    // 立てる。途中の失敗 → retry 成功 で error が残らないようにする。
    let lastError: string | null = null;
    try {
      do {
        pendingDirty = false;
        try {
          opts.setStatus("rendering…");
          const stl = await opts.render(opts.buildSource());
          opts.applyResult(stl);
          lastError = null;
        } catch (e) {
          lastError = e instanceof Error ? e.message : String(e);
        }
      } while (pendingDirty);
      if (lastError !== null) {
        opts.setStatus(`error: ${lastError}`, true);
      } else {
        opts.setStatus("ready");
      }
    } finally {
      isRendering = false;
    }
  };

  return {
    scheduleRerender() {
      if (scheduledTimer) clearTimeout(scheduledTimer);
      scheduledTimer = setTimeout(() => {
        scheduledTimer = null;
        void drive();
      }, debounceMs);
    },
  };
}
