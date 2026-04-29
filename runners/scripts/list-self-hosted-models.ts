#!/usr/bin/env tsx
/**
 * セルフホスト OpenAI 互換 endpoint(LM Studio / Ollama / llama.cpp /
 * vLLM など)の使えるモデル一覧を表示する。情報量の多い順に endpoint
 * を試行:
 *
 *   1. `/api/v0/models` (LM Studio native) — publisher / arch / quant /
 *      max_context_length / state / capabilities が分かる
 *   2. `/api/tags` (Ollama native) — family / parameter_size / quant / size
 *   3. `/v1/models` (OpenAI compat fallback) — id のみ
 *
 * Reads <repoRoot>/.env via process.loadEnvFile。
 * 環境変数: `OPENAI_SELF_HOSTED_BASE_URL`(推奨、`/v1` 込み)、または
 * 旧来の `OLLAMA_HOST`(/v1 を自動補完)。
 *
 * Usage: pnpm --filter runners run list-self-hosted-models [--filter <substr>]
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

const explicitBase = process.env["OPENAI_SELF_HOSTED_BASE_URL"];
const legacy = process.env["OLLAMA_HOST"];
const rawBase = explicitBase
  ? explicitBase
  : legacy
    ? legacy.replace(/\/$/, "") + "/v1"
    : "http://127.0.0.1:11434/v1";
const baseURL = rawBase.replace(/\/$/, "");
const hostRoot = baseURL.replace(/\/v1$/, "");

const filterArg = (() => {
  const idx = process.argv.indexOf("--filter");
  if (idx >= 0) return process.argv[idx + 1];
  return undefined;
})();

interface LMStudioModel {
  id: string;
  type?: string;
  publisher?: string;
  arch?: string;
  quantization?: string;
  state?: string;
  max_context_length?: number;
  capabilities?: string[];
}
interface OllamaTag {
  name: string;
  model?: string;
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
function fmtCtx(n?: number): string {
  if (!n) return "?";
  if (n >= 1024) return `${Math.round(n / 1024)}k`;
  return String(n);
}
const w = (s: string, n: number) => s.padEnd(n);

async function tryLMStudio(): Promise<LMStudioModel[] | null> {
  try {
    const res = await fetch(`${hostRoot}/api/v0/models`);
    if (!res.ok) return null;
    const json = (await res.json()) as { data?: LMStudioModel[] };
    return json.data ?? [];
  } catch {
    return null;
  }
}
async function tryOllamaTags(): Promise<OllamaTag[] | null> {
  try {
    const res = await fetch(`${hostRoot}/api/tags`);
    if (!res.ok) return null;
    const json = (await res.json()) as { models?: OllamaTag[] };
    return json.models ?? [];
  } catch {
    return null;
  }
}
async function tryOpenAIModels(): Promise<V1Model[] | null> {
  try {
    const res = await fetch(`${baseURL}/models`, {
      headers: { authorization: "Bearer self-hosted" },
    });
    if (!res.ok) return null;
    const json = (await res.json()) as { data?: V1Model[] };
    return json.data ?? [];
  } catch {
    return null;
  }
}

const lms = await tryLMStudio();
if (lms && lms.length > 0) {
  // LM Studio native — 一番情報が豊富。type, publisher, arch, quant,
  // ctx, state, capabilities がそろう。
  const filtered = filterArg
    ? lms.filter(
        (m) =>
          m.id.includes(filterArg) ||
          m.publisher?.includes(filterArg) ||
          m.arch?.includes(filterArg),
      )
    : lms;
  console.log(
    `# base: ${hostRoot} (LM Studio native /api/v0/models)\n# ${filtered.length} model(s)${
      filterArg ? ` matching "${filterArg}"` : ""
    }\n`,
  );
  console.log(
    `${w("id", 44)} ${w("type", 5)} ${w("publisher", 18)} ${w("arch", 12)} ${w("quant", 9)} ${w("ctx", 5)} ${w("state", 11)} caps`,
  );
  for (const m of filtered) {
    console.log(
      `${w(m.id, 44)} ${w(m.type ?? "?", 5)} ${w(
        m.publisher ?? "?",
        18,
      )} ${w(m.arch ?? "?", 12)} ${w(m.quantization ?? "?", 9)} ${w(
        fmtCtx(m.max_context_length),
        5,
      )} ${w(m.state ?? "?", 11)} ${(m.capabilities ?? []).join(",")}`,
    );
  }
  process.exit(0);
}

const tags = await tryOllamaTags();
if (tags && tags.length > 0) {
  const filtered = filterArg
    ? tags.filter(
        (m) =>
          m.name.includes(filterArg) ||
          m.model?.includes(filterArg) ||
          m.details?.family?.includes(filterArg),
      )
    : tags;
  console.log(
    `# base: ${hostRoot} (Ollama native /api/tags)\n# ${filtered.length} model(s)${
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
  process.exit(0);
}

const v1 = await tryOpenAIModels();
if (!v1) {
  console.error(`failed to list models from ${baseURL}`);
  console.error(
    `tried /api/v0/models (LM Studio), /api/tags (Ollama), /v1/models (OpenAI compat) — none succeeded`,
  );
  console.error(
    `(set OPENAI_SELF_HOSTED_BASE_URL=http://192.168.x.y:1234/v1 in .env)`,
  );
  process.exit(2);
}
const filtered = filterArg
  ? v1.filter((m) => m.id.includes(filterArg))
  : v1;
console.log(
  `# base: ${baseURL} (OpenAI compat /v1)\n# ${filtered.length} model(s)${
    filterArg ? ` matching "${filterArg}"` : ""
  }\n`,
);
console.log(`${w("id", 50)} owned_by`);
for (const m of filtered) {
  console.log(`${w(m.id, 50)} ${m.owned_by ?? "?"}`);
}
