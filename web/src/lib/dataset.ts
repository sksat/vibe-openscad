import { resolve } from "node:path";
import { computeCostUsd } from "@vibe-openscad/runners/src/pricing.js";
import type { RunMeta } from "@vibe-openscad/runners/src/schema.js";
import { loadDataset } from "./results.js";

/**
 * Locate the repo root from the web/ package and load the dataset.
 *
 * `astro dev` and `astro build` both run with cwd=web/, so the repo root is
 * one directory up. We avoid `import.meta.dirname` because Astro bundles the
 * page module to `web/dist/.prerender/chunks/` at build time and the
 * relative path from there points into dist/, not the repo.
 */
export function getDataset() {
  const repoRoot = resolve(process.cwd(), "..");
  return loadDataset(repoRoot);
}

export function statusBadgeClass(status: string): string {
  if (status === "success") return "badge ok";
  if (status === "no_code" || status === "render_error") return "badge bad";
  if (status === "submit_missing" || status === "timeout") return "badge warn";
  return "badge";
}

/**
 * Best available cost in USD for a run. Prefers `meta.cost_usd` (computed at
 * run time with the price valid then), falls back to the current pricing
 * table when older runs predate cost-capture.
 */
export function runCostUsd(m: RunMeta): number | null {
  if (typeof m.cost_usd === "number") return m.cost_usd;
  if (!m.tokens || !m.provider || !m.model) return null;
  return computeCostUsd(m.provider, m.model, m.tokens);
}

export interface MatrixSegment {
  /** Visual category — drives the badge color. */
  kind: "harness" | "vendor" | "model" | "other";
  label: string;
  title?: string;
  /** Vendor identifier — used for theme tinting. */
  vendor?: "claude" | "gemini" | "openai";
}

const HARNESS_NAMES = new Set([
  "bare",
  "external-agent",
  "cc",
  "claude-code",
]);

/** Parse one model id string into vendor + model badges (or fall through). */
function parseModelLabel(modelStr: string): MatrixSegment[] {
  // Anthropic model: claude-(opus|sonnet|haiku)-MAJOR[-MINOR][-YYYYMMDD]
  // Minor is constrained to 1-3 digits to disambiguate from an 8-digit date
  // (e.g. claude-opus-4-20250514 has no minor, just major + date).
  const claude = modelStr.match(
    /^claude-(opus|sonnet|haiku)-(\d+)(?:-(\d{1,3}))?(?:-(\d{8}))?$/,
  );
  if (claude) {
    let label = claude[3]
      ? `${claude[1]} ${claude[2]}.${claude[3]}`
      : `${claude[1]} ${claude[2]}`;
    if (claude[4]) {
      const d = claude[4];
      label += ` ${d.slice(0, 4)}-${d.slice(4, 6)}-${d.slice(6, 8)}`;
    }
    return [
      { kind: "vendor", label: "claude", vendor: "claude" },
      { kind: "model", label, title: modelStr, vendor: "claude" },
    ];
  }

  // Gemini:
  //   gemini-MAJOR[.MINOR]-(pro|flash-lite|flash)[-(preview|preview-XXX|NNN|latest|exp...)]
  // Examples: gemini-2.5-flash, gemini-3-flash-preview, gemini-3.1-pro-preview
  const gemini = modelStr.match(
    /^gemini-(\d+)(?:\.(\d+))?-(pro|flash-lite|flash)(?:-(preview(?:-[\w-]+)?|\d+|latest|exp[\w-]*))?$/,
  );
  if (gemini) {
    const ver = gemini[2] ? `${gemini[1]}.${gemini[2]}` : gemini[1];
    let label = `${gemini[3]} ${ver}`;
    if (gemini[4]) label += ` ${gemini[4]}`;
    return [
      { kind: "vendor", label: "gemini", vendor: "gemini" },
      { kind: "model", label, title: modelStr, vendor: "gemini" },
    ];
  }

  // OpenAI GPT family: gpt-MAJOR[.MINOR][-(mini|nano|pro|turbo)][-YYYY-MM-DD]
  const gpt = modelStr.match(
    /^gpt-(\d+(?:\.\d+)?)(?:-(mini|nano|pro|turbo))?(?:-(\d{4}-\d{2}-\d{2}|preview|latest))?$/,
  );
  if (gpt) {
    let label = `gpt ${gpt[1]}`;
    if (gpt[2]) label += ` ${gpt[2]}`;
    if (gpt[3]) label += ` ${gpt[3]}`;
    return [
      { kind: "vendor", label: "openai", vendor: "openai" },
      { kind: "model", label, title: modelStr, vendor: "openai" },
    ];
  }

  // OpenAI o-series (reasoning): o3, o4-mini, o3-pro, etc.
  const oseries = modelStr.match(
    /^(o\d+)(?:-(mini|pro|preview))?(?:-(\d{4}-\d{2}-\d{2}))?$/,
  );
  if (oseries) {
    let label = oseries[1]!;
    if (oseries[2]) label += ` ${oseries[2]}`;
    if (oseries[3]) label += ` ${oseries[3]}`;
    return [
      { kind: "vendor", label: "openai", vendor: "openai" },
      { kind: "model", label, title: modelStr, vendor: "openai" },
    ];
  }

  return [{ kind: "other", label: modelStr }];
}

/**
 * Decompose a matrixId like `bare/claude-opus-4-7` into displayable segments
 * so the dashboard can render them as a row of badges instead of one wide
 * string that clips with ellipsis. When the model carries a date suffix it
 * is merged into the model badge so it stays visually associated:
 *
 *   bare/claude-opus-4-7              → bare · claude · opus 4.7
 *   bare/claude-haiku-4-5-20251001    → bare · claude · haiku 4.5 2025-10-01
 *   external-agent/claude-code        → external-agent · claude-code
 */
export function parseMatrixId(matrixId: string): MatrixSegment[] {
  const parts = matrixId.split("/");
  const out: MatrixSegment[] = [];
  for (let i = 0; i < parts.length; i++) {
    const p = parts[i]!;
    if (i === 0 && HARNESS_NAMES.has(p)) {
      out.push({ kind: "harness", label: p });
      continue;
    }
    out.push(...parseModelLabel(p));
  }
  return out;
}

/**
 * Build display badges for an actual run. Same shape as parseMatrixId, but
 * uses the **real** model id from `meta.model` for the model/date badge —
 * so a matrix entry id of `bare/claude-opus-4-5` whose underlying model is
 * `claude-opus-4-5-20251101` shows the date.
 */
export function runBadges(meta: RunMeta): MatrixSegment[] {
  // Order: vendor · model · harness — model identity comes first when
  // scanning cards, harness mode is the trailing qualifier.
  const out: MatrixSegment[] = [];
  if (meta.model) out.push(...parseModelLabel(meta.model));
  const headPart = meta.matrixId.split("/")[0];
  if (headPart && HARNESS_NAMES.has(headPart)) {
    out.push({ kind: "harness", label: headPart });
  } else {
    out.push({ kind: "harness", label: meta.harness.kind });
  }
  return out;
}

/** Format a USD cost compactly. Returns "—" for null. */
export function formatCost(usd: number | null | undefined): string {
  if (usd == null) return "—";
  if (usd === 0) return "$0";
  if (usd < 0.0001) return "<$0.0001";
  if (usd < 1) return `$${usd.toFixed(4)}`;
  return `$${usd.toFixed(2)}`;
}
