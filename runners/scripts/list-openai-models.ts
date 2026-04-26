#!/usr/bin/env tsx
/**
 * Print the OpenAI model IDs available to the configured API key.
 * Reads <repoRoot>/.env via process.loadEnvFile.
 *
 * Usage: pnpm --filter runners run list-openai-models [--filter <substr>]
 */
import { dirname, join, resolve } from "node:path";
import { readFileSync } from "node:fs";
import OpenAI from "openai";

function findRepoRoot(start: string): string {
  let dir = start;
  for (let i = 0; i < 10; i++) {
    try {
      readFileSync(join(dir, "bench-config.yml"));
      return dir;
    } catch {
      const parent = dirname(dir);
      if (parent === dir) break;
      dir = parent;
    }
  }
  return start;
}

const root = findRepoRoot(process.cwd());
try {
  process.loadEnvFile(join(root, ".env"));
} catch {
  /* no .env */
}

if (!process.env["OPENAI_API_KEY"]) {
  console.error("OPENAI_API_KEY not set (.env or env). Cannot list models.");
  process.exit(2);
}

const filterArg = (() => {
  const idx = process.argv.indexOf("--filter");
  if (idx >= 0) return process.argv[idx + 1];
  return undefined;
})();

const client = new OpenAI();
const models = await client.models.list();
const ids: string[] = [];
for await (const m of models) ids.push(m.id);
ids.sort();

const filtered = filterArg
  ? ids.filter((id) => id.includes(filterArg))
  : ids;

console.log(`# ${filtered.length} model(s)${filterArg ? ` matching "${filterArg}"` : ""}\n`);
for (const id of filtered) console.log(id);
