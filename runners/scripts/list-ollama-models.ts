#!/usr/bin/env tsx
/**
 * Print model IDs available on the configured Ollama / LM Studio host
 * via the OpenAI-compat `/v1/models` endpoint. Falls back to Ollama
 * native `/api/tags` (which has richer info: family / params / quant /
 * size) when /v1/models isn't available.
 *
 * Reads <repoRoot>/.env via process.loadEnvFile so OLLAMA_HOST is picked up.
 *
 * Usage: pnpm --filter runners run list-ollama-models [--filter <substr>]
 */
import { dirname, join } from "node:path";
import { readFileSync } from "node:fs";

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

const host = (
  process.env["OLLAMA_HOST"] ?? "http://127.0.0.1:11434"
).replace(/\/$/, "");

const filterArg = (() => {
  const idx = process.argv.indexOf("--filter");
  if (idx >= 0) return process.argv[idx + 1];
  return undefined;
})();

interface OllamaTag {
  name: string;
  model: string;
  size?: number;
  details?: {
    parameter_size?: string;
    quantization_level?: string;
    family?: string;
  };
}

interface V1Model {
  id: string;
  owned_by?: string;
}

function fmtSize(n?: number): string {
  if (!n) return "—";
  const gb = n / (1024 * 1024 * 1024);
  if (gb >= 1) return `${gb.toFixed(2)} GB`;
  return `${(n / (1024 * 1024)).toFixed(1)} MB`;
}

async function tryOllamaTags(): Promise<OllamaTag[] | null> {
  try {
    const res = await fetch(`${host}/api/tags`);
    if (!res.ok) return null;
    const json = (await res.json()) as { models?: OllamaTag[] };
    return json.models ?? [];
  } catch {
    return null;
  }
}

async function tryOpenAIModels(): Promise<V1Model[] | null> {
  try {
    const res = await fetch(`${host}/v1/models`, {
      headers: { authorization: "Bearer ollama" },
    });
    if (!res.ok) return null;
    const json = (await res.json()) as { data?: V1Model[] };
    return json.data ?? [];
  } catch {
    return null;
  }
}

const w = (s: string, n: number) => s.padEnd(n);

const tags = await tryOllamaTags();
if (tags && tags.length > 0) {
  // Ollama-native API が応答した(豊富な情報があるのでこちらを優先表示)
  const filtered = filterArg
    ? tags.filter(
        (m) =>
          m.name.includes(filterArg) ||
          m.model?.includes(filterArg) ||
          m.details?.family?.includes(filterArg),
      )
    : tags;
  console.log(
    `# host: ${host} (Ollama native)\n# ${filtered.length} model(s)${
      filterArg ? ` matching "${filterArg}"` : ""
    }\n`,
  );
  console.log(
    `${w("name", 40)} ${w("family", 14)} ${w("params", 10)} ${w("quant", 10)} size`,
  );
  for (const m of filtered) {
    console.log(
      `${w(m.name, 40)} ${w(m.details?.family ?? "?", 14)} ${w(
        m.details?.parameter_size ?? "?",
        10,
      )} ${w(m.details?.quantization_level ?? "?", 10)} ${fmtSize(m.size)}`,
    );
  }
} else {
  // OpenAI 互換のみ(LM Studio 等)
  const v1 = await tryOpenAIModels();
  if (!v1) {
    console.error(`failed to list models from ${host}`);
    console.error(
      `tried /api/tags (Ollama) and /v1/models (OpenAI compat) — neither succeeded`,
    );
    console.error(`(set OLLAMA_HOST in .env, e.g. OLLAMA_HOST=http://192.168.x.y:1234)`);
    process.exit(2);
  }
  const filtered = filterArg
    ? v1.filter((m) => m.id.includes(filterArg))
    : v1;
  console.log(
    `# host: ${host} (OpenAI compat /v1)\n# ${filtered.length} model(s)${
      filterArg ? ` matching "${filterArg}"` : ""
    }\n`,
  );
  console.log(`${w("id", 50)} owned_by`);
  for (const m of filtered) {
    console.log(`${w(m.id, 50)} ${m.owned_by ?? "?"}`);
  }
}
