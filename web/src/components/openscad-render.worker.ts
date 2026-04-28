/// <reference lib="webworker" />
/**
 * openscad-wasm はレンダリング(callMain)がメインスレッドを同期ブロック
 * するため、スライダーで頻繁に再レンダリングすると UI が固まる。worker
 * 内に閉じ込めて、メインスレッドはメッセージで結果を受け取るだけにする。
 *
 * Emscripten の callMain は失敗時に exit code(数字)で throw する。また
 * このパッケージのラッパーは `var err = console.error.bind(console)` で
 * stderr を console に bind して固定しており、`Module.printErr` は読まない。
 * 実エラーメッセージ(`ERROR: Parser ... line N`)を捕まえるには wasm を
 * 評価する前に console を差し替えて bind 越しに拾う必要がある。
 *
 * ★ 実装ノート: 静的 import は ESM の依存グラフ評価で「ソース順で先の
 * 副作用 import が先に評価される」性質を持つので、`openscad-render-console`
 * を先に書くことで openscad-wasm の IIFE が走る前に console を差し替え
 * られる。動的 import (`await import`) は Vite の worker 環境で挙動が
 * 不安定だったため避ける。
 */
import { stderrBuf, captureHandle } from "./openscad-render-console.js";
import { createOpenSCAD } from "openscad-wasm";
import { buildErrorMessage } from "./openscad-render-error.js";

// openscad-wasm の IIFE 評価が終わった(stderr の bind が capture を指して
// いる)ので、console は元に戻して他のコードに迷惑をかけないようにする。
captureHandle.uninstall();

type RenderRequest = { id: number; scad: string };
type RenderResponse =
  | { id: number; stlText: string }
  | { id: number; error: string };

const instancePromise = createOpenSCAD();

// 同時に複数メッセージが来ても、各 render 中は stderrBuf を排他的に
// 扱いたい。Promise chain でメッセージ処理を直列化する(callMain も
// 1 個の wasm instance を共有するため、並走させると /input.scad /
// /output.scad のファイルが競合する)。
let queue: Promise<void> = Promise.resolve();
self.onmessage = (e: MessageEvent<RenderRequest>) => {
  queue = queue.then(() => handle(e.data));
};

async function handle(req: RenderRequest): Promise<void> {
  const { id, scad } = req;
  try {
    const instance = await instancePromise;
    stderrBuf.length = 0;
    const stlText = await instance.renderToStl(scad);
    const reply: RenderResponse = { id, stlText };
    (self as unknown as Worker).postMessage(reply);
  } catch (err) {
    const stderr = stderrBuf.join("\n");
    const message = buildErrorMessage(stderr, err);
    const reply: RenderResponse = { id, error: message };
    (self as unknown as Worker).postMessage(reply);
  }
}
