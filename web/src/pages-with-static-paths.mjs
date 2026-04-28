/**
 * Single source of truth for "page modules that depend on results/"。
 * astro.config.mjs の watcher と TDD テストの両方が import する。
 *
 * 新しい dynamic page (getStaticPaths を持つ .astro) を追加したら、
 * このリストにも追加する必要がある。サニティ test (configurable.test.ts)
 * が抜け漏れを検出する。
 */
import { resolve } from "node:path";

/** web/ project root から見た page パスのリスト。watcher が invalidate
 *  対象として使う。getStaticPaths を持つ全 page を網羅する。 */
export const PAGES_WITH_STATIC_PATHS = [
  "./src/pages/run/[id].astro",
  "./src/pages/task/[slug].astro",
  "./src/pages/task/[slug]/[model].astro",
  "./src/pages/models/[id].astro",
  "./src/pages/harnesses/[id].astro",
  "./src/pages/index.astro",
];

/** Resolve to absolute paths for use with Vite/Astro's moduleGraph. */
export function pagesWithStaticPathsAbs() {
  return PAGES_WITH_STATIC_PATHS.map((p) => resolve(p));
}
