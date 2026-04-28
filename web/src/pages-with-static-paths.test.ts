import { readFileSync, readdirSync, statSync } from "node:fs";
import { extname, join, resolve } from "node:path";
import { describe, expect, it } from "vitest";
import { PAGES_WITH_STATIC_PATHS } from "./pages-with-static-paths.mjs";

const PAGES_DIR = resolve("src/pages");

function listAstroFiles(dir: string): string[] {
  const out: string[] = [];
  for (const entry of readdirSync(dir)) {
    const p = join(dir, entry);
    const s = statSync(p);
    if (s.isDirectory()) out.push(...listAstroFiles(p));
    else if (extname(entry) === ".astro") out.push(p);
  }
  return out;
}

function hasGetStaticPaths(file: string): boolean {
  const src = readFileSync(file, "utf8");
  // crude but sufficient: look for the export string. Pages without it
  // don't get cached on getStaticPaths so don't need to be invalidated.
  return /getStaticPaths\s*\(/.test(src);
}

describe("PAGES_WITH_STATIC_PATHS coverage", () => {
  it("lists every .astro page that defines getStaticPaths()", () => {
    const known = new Set(
      (PAGES_WITH_STATIC_PATHS as string[]).map((p) => resolve(p)),
    );
    const allPages = listAstroFiles(PAGES_DIR);
    const dynamicPages = allPages.filter(hasGetStaticPaths);
    const missing = dynamicPages.filter((p) => !known.has(p));
    expect(missing).toEqual([]);
  });

  it("does not list any page that doesn't exist on disk", () => {
    for (const p of PAGES_WITH_STATIC_PATHS as string[]) {
      const abs = resolve(p);
      expect(() => statSync(abs)).not.toThrow();
    }
  });
});
