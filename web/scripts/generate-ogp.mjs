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

/** Short display label for a model id (vendor + family). */
function shortModelLabel(model) {
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

  let made = 0;
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
    made++;
    console.log(
      `[generate-ogp] ${task.id}: ${picks.length} pick(s) → ${outPath}`,
    );
  }
  console.log(`[generate-ogp] generated ${made} task card(s)`);
}

main().catch((e) => {
  console.error("[generate-ogp] failed:", e);
  process.exit(1);
});
