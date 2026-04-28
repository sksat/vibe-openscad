/**
 * 副作用インポート専用モジュール。openscad-wasm の Emscripten ラッパーは
 * 評価時(IIFE 内)に `console.error.bind(console)` で stderr 参照を固定
 * するため、wasm モジュールが評価される *前に* console を差し替えて
 * おかなければならない。ESM では「他のモジュールよりソース順で先の
 * 副作用インポート」がまさにそのタイミングを保証する。
 *
 * 使用例(worker 側):
 *   // この import は openscad-wasm より上に書く。
 *   import { stderrBuf, captureHandle } from "./openscad-render-console.js";
 *   import { createOpenSCAD } from "openscad-wasm"; // ← bind は capture を見る
 *   captureHandle.uninstall(); // bind 後は元に戻して OK
 */
import { installConsoleCapture } from "./openscad-render-error.js";

export const stderrBuf: string[] = [];
export const captureHandle = installConsoleCapture(stderrBuf);
