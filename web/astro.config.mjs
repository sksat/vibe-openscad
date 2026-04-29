import { defineConfig } from "astro/config";
import { watch } from "node:fs";
import { resolve } from "node:path";

const RESULTS_DIR = resolve("..", "results");

/**
 * Astro caches getStaticPaths() at server boot, and Vite's watcher ignores
 * paths outside the project root. We use Node's fs.watch (recursive) on
 * `../results/` so that `pnpm bench run` results show up live.
 *
 * 設計判断: ここでは「特定 page module を id で invalidate する」のは諦めて
 * **moduleGraph 全体を invalidate** + full-reload する。
 * 理由: rest-param dynamic route(`/models/[...id].astro` 等)は誰も踏むまで
 * moduleGraph に入らない。新しいモデル(= 新しい URL)を期待しているのに
 * `getModuleById(p)` が null を返して invalidate が no-op になり、結果
 * 「新しいモデルだけ 404 のまま」という症状が出る。全部 invalidate しても
 * dev では cheap(Vite が次回リクエスト時に lazy 再評価するだけ)なので
 * 確実性を取る。
 */
function watchResults() {
  return {
    name: "watch-results",
    configureServer(server) {
      let timer = null;
      let watcher;
      try {
        watcher = watch(RESULTS_DIR, { recursive: true }, () => {
          // debounce burst writes (a single bench run writes several files)
          if (timer) clearTimeout(timer);
          timer = setTimeout(() => {
            timer = null;
            for (const mod of server.moduleGraph.idToModuleMap.values()) {
              server.moduleGraph.invalidateModule(mod);
            }
            server.ws.send({ type: "full-reload", path: "*" });
            server.config.logger.info(
              `[watch-results] results/ changed → reload`,
              { timestamp: true },
            );
          }, 150);
        });
      } catch (e) {
        server.config.logger.warn(
          `[watch-results] cannot watch ${RESULTS_DIR}: ${e.message}`,
        );
        return;
      }
      server.httpServer?.once("close", () => watcher.close());
    },
  };
}

// Public site URL — used to absolutize og:image / og:url. Override with the
// SITE_URL env var when deploying to a custom domain.
const SITE = process.env.SITE_URL ?? "https://vibe-openscad.sksat.dev";

export default defineConfig({
  site: SITE,
  output: "static",
  trailingSlash: "ignore",
  build: {
    format: "directory",
  },
  vite: {
    optimizeDeps: {
      exclude: ["three", "openscad-wasm"],
    },
    // worker 内で dynamic import (openscad-wasm を console 差し替え後に
    // 評価したいため)するので code-splitting が必要。default の iife は
    // それを許さないので es module 出力にする。
    worker: {
      format: "es",
    },
    plugins: [watchResults()],
  },
});
