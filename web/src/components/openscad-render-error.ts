/**
 * openscad-wasm が render 失敗時に出す「投げられたもの」と
 * printErr で集めた stderr を、UI に出すエラーメッセージにまとめる。
 *
 * Emscripten の callMain は失敗時にいろいろなものを throw するので、
 * 単に `String(err)` するとユーザに「数字だけ」が出てしまい何も伝わら
 * ない。stderr に openscad 自身の "ERROR: ..." メッセージがあれば
 * それを最優先で見せる。
 */

/**
 * 投げられた何か(Error / 数字 / ExitStatus 風 / 文字列)を 1 行に
 * 言語化する。出せるものが何も無ければ空文字を返す。
 */
export function formatThrown(err: unknown): string {
  if (err instanceof Error) return err.message;
  if (typeof err === "number") return `exit(${err})`;
  if (err && typeof err === "object") {
    const obj = err as { message?: unknown; status?: unknown };
    if (typeof obj.message === "string" && obj.message) return obj.message;
    if (typeof obj.status === "number") return `exit(${obj.status})`;
  }
  if (typeof err === "string" && err) return err;
  return "";
}

/**
 * worker から main thread に返すエラーメッセージを構築する。
 * - stderr(printErr 経由のキャプチャ)があれば最優先
 * - throw された値は補助情報として末尾に付ける
 * - 両方とも空のときは "(no error message)" を出す(数字だけ・空文字
 *   などで「何も無い」状態を防ぐ)
 */
export function buildErrorMessage(stderr: string, err: unknown): string {
  const trimmed = stderr.trim();
  const summary = formatThrown(err);
  if (trimmed && summary) return `${trimmed}\n(${summary})`;
  if (trimmed) return trimmed;
  if (summary) return summary;
  return "OpenSCAD failed (no error message)";
}

/**
 * openscad-wasm の Emscripten ラッパーは `var err = console.error.bind(console)`
 * のように console を bind して固定参照にしてしまっており、Module.printErr
 * では拾えない。仕方ないので、wasm を import する直前に console.log /
 * console.error を差し替え、その瞬間の参照を bind に拾わせる。bind 済み
 * 参照は変数に固定されるので、import が終わったあと console を元に戻して
 * も capture は生き続ける。
 */
export interface ConsoleCaptureHandle {
  /** 元の console.log / console.error を復元する。capture 自体(bind 済み
   *  参照)は復元後も buffer に書き込み続ける。 */
  uninstall(): void;
}

export function installConsoleCapture(
  buffer: string[],
): ConsoleCaptureHandle {
  const origLog = console.log;
  const origError = console.error;
  const capture = (...args: unknown[]): void => {
    buffer.push(
      args
        .map((a) => (typeof a === "string" ? a : String(a)))
        .join(" "),
    );
  };
  console.log = capture;
  console.error = capture;
  let installed = true;
  return {
    uninstall(): void {
      if (!installed) return;
      installed = false;
      console.log = origLog;
      console.error = origError;
    },
  };
}
