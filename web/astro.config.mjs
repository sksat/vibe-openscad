import { defineConfig } from "astro/config";
import { watch } from "node:fs";
import { resolve } from "node:path";
import { pagesWithStaticPathsAbs } from "./src/pages-with-static-paths.mjs";

const RESULTS_DIR = resolve("..", "results");
const PAGES = pagesWithStaticPathsAbs();

/**
 * Astro caches getStaticPaths() at server boot, and Vite's watcher ignores
 * paths outside the project root. We use Node's fs.watch (recursive) on
 * `../results/` so that `pnpm bench run` results show up live: invalidate
 * the page modules → full browser reload → getStaticPaths re-runs.
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
            for (const p of PAGES) {
              const mod = server.moduleGraph.getModuleById(p);
              if (mod) server.moduleGraph.invalidateModule(mod);
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
      exclude: ["three"],
    },
    plugins: [watchResults()],
  },
});
