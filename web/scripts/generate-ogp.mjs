#!/usr/bin/env node
/**
 * Pre-build step: synthesize per-task OGP cards (1200x630 PNG) by
 * compositing 2x2 thumbnails of representative model renders for each
 * task. Output goes to `web/public/og/task-<task-id>.png` so Astro picks
 * them up as static assets.
 *
 * Run automatically as part of the `build` script (see web/package.json).
 * Skipped when sharp is unavailable or no results exist.
 */
import { existsSync, mkdirSync, readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import sharp from "sharp";
import { parse as parseYaml } from "yaml";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const repoRoot = resolve(__dirname, "..", "..");
const resultsDir = join(repoRoot, "results");
const tasksDir = join(repoRoot, "tasks");
const outDir = join(repoRoot, "web", "public", "og");

const W = 1200;
const H = 630;
const GAP = 12;
const PADDING = 24;
const HEADER_HEIGHT = 80;
const CELL_W = Math.floor((W - PADDING * 2 - GAP) / 2);
const CELL_H = Math.floor((H - PADDING * 2 - GAP - HEADER_HEIGHT) / 2);
const LABEL_HEIGHT = 28;

// Model preference order — same as task page's pickOgpImage but slightly
// extended for the 4-pick grid.
const PREFERRED_MODELS = [
  "claude-opus-4-7",
  "gpt-5.4-2026-03-05",
  "gemini-3.1-pro-preview",
  "claude-sonnet-4-6",
  "gpt-5-2025-08-07",
  "gemini-2.5-pro",
  "claude-opus-4-5-20251101",
  "claude-haiku-4-5-20251001",
  "gpt-5.4-mini-2026-03-17",
  "gemini-3-flash-preview",
];

/**
 * モデルカタログ(models.yml)の `label:` 宣言。命名規則から外れる id
 * (gpt-5.6-sol 等)はここで表示名が決まる。カード生成はページ本体と
 * 別プロセスなので、同じカタログを読んで表示を一致させる。
 */
const declaredLabels = (() => {
  try {
    const raw = parseYaml(readFileSync(join(repoRoot, "models.yml"), "utf8"));
    const out = [];
    for (const [prefix, entry] of Object.entries(raw ?? {})) {
      if (entry && typeof entry.label === "string") out.push([prefix, entry.label]);
    }
    // 最長 prefix を勝たせる(models.ts の解決規則と同じ)。
    return out.sort((a, b) => b[0].length - a[0].length);
  } catch {
    return [];
  }
})();

/** Short display label for a model id (vendor + family). */
function shortModelLabel(model) {
  for (const [prefix, label] of declaredLabels) {
    if (model.startsWith(prefix)) return label;
  }
  const claude = model.match(/^claude-(opus|sonnet|haiku)-(\d+)(?:-(\d{1,3}))?/);
  if (claude) {
    const ver = claude[3] ? `${claude[2]}.${claude[3]}` : claude[2];
    return `claude ${claude[1]} ${ver}`;
  }
  const gpt = model.match(/^gpt-(\d+(?:\.\d+)?)(?:-(mini|nano|pro))?/);
  if (gpt) return `gpt ${gpt[1]}${gpt[2] ? ` ${gpt[2]}` : ""}`;
  const oseries = model.match(/^(o\d+)(?:-(mini|pro))?/);
  if (oseries) return `${oseries[1]}${oseries[2] ? ` ${oseries[2]}` : ""}`;
  const gemini = model.match(/^gemini-(\d+(?:\.\d+)?)-(pro|flash-lite|flash)/);
  if (gemini) return `gemini ${gemini[1]} ${gemini[2]}`;
  return model;
}

function loadTasks() {
  if (!existsSync(tasksDir)) return [];
  const out = [];
  const walk = (dir) => {
    for (const entry of readdirSync(dir)) {
      const p = join(dir, entry);
      const s = statSync(p);
      if (s.isDirectory()) walk(p);
      else if (entry.endsWith(".yml") || entry.endsWith(".yaml")) {
        const raw = readFileSync(p, "utf8");
        // crude id extraction; full YAML parse not needed
        const idMatch = raw.match(/^\s*id:\s*([\w-]+)/m);
        const titleMatch = raw.match(/^\s*title:\s*(.+)$/m);
        if (idMatch) {
          out.push({
            id: idMatch[1],
            title: titleMatch ? titleMatch[1].trim() : idMatch[1],
          });
        }
      }
    }
  };
  walk(tasksDir);
  return out;
}

/** Find default-bare runs for a task and pick up to 4 in preference order. */
function pickRunsForTask(taskId) {
  const taskDir = join(resultsDir, taskId);
  if (!existsSync(taskDir)) return [];
  const candidates = [];
  for (const runDir of readdirSync(taskDir)) {
    const metaPath = join(taskDir, runDir, "meta.json");
    const pngPath = join(taskDir, runDir, "final.png");
    if (!existsSync(metaPath) || !existsSync(pngPath)) continue;
    let meta;
    try {
      meta = JSON.parse(readFileSync(metaPath, "utf8"));
    } catch {
      continue;
    }
    if (!meta.matrixId?.startsWith("bare/")) continue; // skip iter / variants
    if (meta.status !== "success") continue;
    candidates.push({ meta, pngPath });
  }
  // Newest per matrixId.
  const byMatrix = new Map();
  for (const c of candidates) {
    const ex = byMatrix.get(c.meta.matrixId);
    if (!ex || ex.meta.createdAt < c.meta.createdAt) {
      byMatrix.set(c.meta.matrixId, c);
    }
  }
  // Pick 4 in preference order, then fill from the rest by createdAt desc.
  const picked = [];
  const seen = new Set();
  for (const model of PREFERRED_MODELS) {
    if (picked.length >= 4) break;
    for (const c of byMatrix.values()) {
      if (c.meta.model === model) {
        picked.push(c);
        seen.add(c.meta.matrixId);
        break;
      }
    }
  }
  if (picked.length < 4) {
    const rest = [...byMatrix.values()]
      .filter((c) => !seen.has(c.meta.matrixId))
      .sort((a, b) => (a.meta.createdAt < b.meta.createdAt ? 1 : -1));
    for (const c of rest) {
      if (picked.length >= 4) break;
      picked.push(c);
    }
  }
  return picked;
}

/** Escape XML/SVG-sensitive characters. */
function escapeXml(s) {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function headerSvg(title) {
  return `
<svg width="${W}" height="${HEADER_HEIGHT}" xmlns="http://www.w3.org/2000/svg">
  <style>
    .brand { font: 600 22px ui-monospace, "JetBrains Mono", "SF Mono", Menlo, monospace; fill: #6cb6ff; }
    .title { font: 500 28px ui-sans-serif, system-ui, sans-serif; fill: #d6dee8; }
    .sub   { font: 14px ui-monospace, "SF Mono", monospace; fill: #8a96a3; }
  </style>
  <text x="${PADDING}" y="38" class="brand">vibe-openscad</text>
  <text x="${PADDING}" y="68" class="title">${escapeXml(title)}</text>
</svg>`;
}

function labelSvg(text) {
  return `
<svg width="${CELL_W}" height="${LABEL_HEIGHT}" xmlns="http://www.w3.org/2000/svg">
  <rect x="0" y="0" width="${CELL_W}" height="${LABEL_HEIGHT}" fill="#000" fill-opacity="0.62"/>
  <text x="10" y="19" font-family="ui-monospace, &quot;SF Mono&quot;, monospace" font-size="13" fill="#ffffff">${escapeXml(text)}</text>
</svg>`;
}

async function buildTaskCard(task, picks) {
  const composites = [];
  // Header.
  composites.push({
    input: Buffer.from(headerSvg(task.title)),
    left: 0,
    top: 0,
  });
  // Cells.
  for (let i = 0; i < 4; i++) {
    const pick = picks[i];
    const col = i % 2;
    const row = Math.floor(i / 2);
    const x = PADDING + col * (CELL_W + GAP);
    const y = HEADER_HEIGHT + PADDING / 2 + row * (CELL_H + GAP);
    if (!pick) {
      // Empty placeholder.
      const placeholderSvg = `
<svg width="${CELL_W}" height="${CELL_H}" xmlns="http://www.w3.org/2000/svg">
  <rect width="${CELL_W}" height="${CELL_H}" fill="#1f262e" stroke="#2a323b" stroke-dasharray="6 4"/>
  <text x="50%" y="50%" text-anchor="middle" font-family="ui-monospace, monospace" font-size="14" fill="#8a96a3">—</text>
</svg>`;
      composites.push({ input: Buffer.from(placeholderSvg), left: x, top: y });
      continue;
    }
    const img = await sharp(pick.pngPath)
      .resize(CELL_W, CELL_H, { fit: "contain", background: "#ffffff" })
      .png()
      .toBuffer();
    composites.push({ input: img, left: x, top: y });
    composites.push({
      input: Buffer.from(labelSvg(shortModelLabel(pick.meta.model))),
      left: x,
      top: y + CELL_H - LABEL_HEIGHT,
    });
  }
  return sharp({
    create: { width: W, height: H, channels: 3, background: "#0e1116" },
  })
    .composite(composites)
    .png()
    .toBuffer();
}

/**
 * モデル毎の OGP 用に「このモデルの bare run を tier 別に最大 4 個」
 * 拾う。tier 1〜N から 1 件ずつ取って多様性を保ち、足りなければ
 * 残りの tier を埋める。
 */
function pickRunsForModel(model) {
  if (!existsSync(resultsDir)) return [];
  // tier の引きには task 一覧が必要なので作っておく。
  const taskIdToTier = new Map();
  for (const t of loadTasks()) {
    // crude tier 抽出 (loadTasks は title しか取ってない)
    const yamlPath = (() => {
      const stack = [tasksDir];
      while (stack.length) {
        const d = stack.pop();
        for (const e of readdirSync(d)) {
          const p = join(d, e);
          if (statSync(p).isDirectory()) stack.push(p);
          else if (
            e.endsWith(".yml") &&
            readFileSync(p, "utf8").includes(`id: ${t.id}`)
          ) {
            return p;
          }
        }
      }
      return null;
    })();
    if (!yamlPath) continue;
    const m = readFileSync(yamlPath, "utf8").match(/^\s*tier:\s*(\d+)/m);
    taskIdToTier.set(t.id, m ? Number(m[1]) : 99);
  }
  // この model の bare/* 成功 run を全 task 横断で集める。
  const candidates = [];
  for (const taskDir of readdirSync(resultsDir)) {
    const taskAbs = join(resultsDir, taskDir);
    if (!statSync(taskAbs).isDirectory()) continue;
    for (const runDir of readdirSync(taskAbs)) {
      const metaPath = join(taskAbs, runDir, "meta.json");
      const pngPath = join(taskAbs, runDir, "final.png");
      if (!existsSync(metaPath) || !existsSync(pngPath)) continue;
      let meta;
      try {
        meta = JSON.parse(readFileSync(metaPath, "utf8"));
      } catch {
        continue;
      }
      if (meta.model !== model) continue;
      // bare/* (default effort) のみ。effort 別 / iter は OGP では混ぜない。
      // pdf-page も許容(tier-4 vision モデル)。
      if (
        !meta.matrixId?.startsWith("bare/") &&
        !meta.matrixId?.startsWith("pdf-page/")
      ) continue;
      if (meta.status !== "success") continue;
      candidates.push({ meta, pngPath, tier: taskIdToTier.get(meta.taskId) ?? 99 });
    }
  }
  if (candidates.length === 0) return [];
  // 同 task 内の最新を newest に丸める。
  const byTask = new Map();
  for (const c of candidates) {
    const ex = byTask.get(c.meta.taskId);
    if (!ex || ex.meta.createdAt < c.meta.createdAt) byTask.set(c.meta.taskId, c);
  }
  // tier 昇順で 1 件ずつ拾う(多様性)。同 tier 内は createdAt 新しい順。
  const byTier = new Map();
  for (const c of byTask.values()) {
    const list = byTier.get(c.tier) ?? [];
    list.push(c);
    byTier.set(c.tier, list);
  }
  const tiers = [...byTier.keys()].sort((a, b) => a - b);
  const picked = [];
  // 1 周目: 各 tier から 1 件ずつ
  for (const t of tiers) {
    if (picked.length >= 4) break;
    const sorted = byTier
      .get(t)
      .sort((a, b) => (a.meta.createdAt < b.meta.createdAt ? 1 : -1));
    picked.push(sorted[0]);
  }
  // 2 周目以降: 余った tier 内から拾い増す
  if (picked.length < 4) {
    const seen = new Set(picked.map((p) => p.meta.runId));
    for (const t of tiers) {
      if (picked.length >= 4) break;
      const sorted = byTier
        .get(t)
        .sort((a, b) => (a.meta.createdAt < b.meta.createdAt ? 1 : -1));
      for (const c of sorted) {
        if (picked.length >= 4) break;
        if (seen.has(c.meta.runId)) continue;
        picked.push(c);
        seen.add(c.meta.runId);
      }
    }
  }
  return picked;
}

/**
 * モデル OGP カード: title が `<vendor> <family> <ver>` 等の short label、
 * cells はそのモデルが解いた tier 1〜4 の代表 run。 cells のラベルは
 * 「task id + tier」で、同モデル内でも task が違うのが読み取れる。
 */
async function buildModelCard(model, picks) {
  const composites = [];
  composites.push({
    input: Buffer.from(headerSvg(shortModelLabel(model))),
    left: 0,
    top: 0,
  });
  for (let i = 0; i < 4; i++) {
    const pick = picks[i];
    const col = i % 2;
    const row = Math.floor(i / 2);
    const x = PADDING + col * (CELL_W + GAP);
    const y = HEADER_HEIGHT + PADDING / 2 + row * (CELL_H + GAP);
    if (!pick) {
      const placeholderSvg = `
<svg width="${CELL_W}" height="${CELL_H}" xmlns="http://www.w3.org/2000/svg">
  <rect width="${CELL_W}" height="${CELL_H}" fill="#1f262e" stroke="#2a323b" stroke-dasharray="6 4"/>
  <text x="50%" y="50%" text-anchor="middle" font-family="ui-monospace, monospace" font-size="14" fill="#8a96a3">—</text>
</svg>`;
      composites.push({ input: Buffer.from(placeholderSvg), left: x, top: y });
      continue;
    }
    const img = await sharp(pick.pngPath)
      .resize(CELL_W, CELL_H, { fit: "contain", background: "#ffffff" })
      .png()
      .toBuffer();
    composites.push({ input: img, left: x, top: y });
    composites.push({
      input: Buffer.from(
        labelSvg(
          `tier ${pick.tier} · ${pick.meta.taskId.replace(/^tier-\d+-/, "")}`,
        ),
      ),
      left: x,
      top: y + CELL_H - LABEL_HEIGHT,
    });
  }
  return sharp({
    create: { width: W, height: H, channels: 3, background: "#0e1116" },
  })
    .composite(composites)
    .png()
    .toBuffer();
}

function loadAllModels() {
  if (!existsSync(resultsDir)) return [];
  const set = new Set();
  for (const taskDir of readdirSync(resultsDir)) {
    const taskAbs = join(resultsDir, taskDir);
    if (!statSync(taskAbs).isDirectory()) continue;
    for (const runDir of readdirSync(taskAbs)) {
      const metaPath = join(taskAbs, runDir, "meta.json");
      if (!existsSync(metaPath)) continue;
      try {
        const meta = JSON.parse(readFileSync(metaPath, "utf8"));
        if (meta.model) set.add(meta.model);
      } catch {
        // ignore
      }
    }
  }
  return [...set].sort();
}

async function main() {
  if (!existsSync(resultsDir)) {
    console.warn("[generate-ogp] no results/ dir, skipping");
    return;
  }
  if (!existsSync(outDir)) mkdirSync(outDir, { recursive: true });

  const tasks = loadTasks();
  if (tasks.length === 0) {
    console.warn("[generate-ogp] no tasks found, skipping");
    return;
  }

  let madeTasks = 0;
  for (const task of tasks) {
    const picks = pickRunsForTask(task.id);
    if (picks.length === 0) {
      console.warn(`[generate-ogp] ${task.id}: no successful bare runs, skipping`);
      continue;
    }
    const png = await buildTaskCard(task, picks);
    const outPath = join(outDir, `task-${task.id}.png`);
    const fs = await import("node:fs");
    fs.writeFileSync(outPath, png);
    madeTasks++;
    console.log(
      `[generate-ogp] ${task.id}: ${picks.length} pick(s) → ${outPath}`,
    );
  }
  console.log(`[generate-ogp] generated ${madeTasks} task card(s)`);

  const models = loadAllModels();
  let madeModels = 0;
  for (const model of models) {
    const picks = pickRunsForModel(model);
    if (picks.length === 0) {
      console.warn(`[generate-ogp] model ${model}: no usable bare runs, skipping`);
      continue;
    }
    const png = await buildModelCard(model, picks);
    // モデル id にスラッシュ(`google/gemma-3-27b` 等)が混じると
    // パスとして解釈されてしまうので、ファイル名用にサニタイズする。
    const safeModel = model.replace(/[\\/]/g, "_");
    const outPath = join(outDir, `model-${safeModel}.png`);
    const fs = await import("node:fs");
    fs.writeFileSync(outPath, png);
    madeModels++;
    console.log(
      `[generate-ogp] model ${model}: ${picks.length} pick(s) → ${outPath}`,
    );
  }
  console.log(`[generate-ogp] generated ${madeModels} model card(s)`);
}

main().catch((e) => {
  console.error("[generate-ogp] failed:", e);
  process.exit(1);
});
