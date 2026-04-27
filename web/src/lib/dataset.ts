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
  /**
   * Override the default href derived from `kind` + `label`. Used when the
   * harness label and the harness group slug differ — e.g., a label of
   * `iter-png-2` linking back to `/harnesses/iter-png/`.
   */
  href?: string;
}

const HARNESS_NAMES = new Set([
  "bare",
  "external-agent",
  "cc",
  "claude-code",
]);

/**
 * Treat the matrixId head as a harness label when it matches one of the
 * known names or a `bare-<variant>` form (e.g. `bare-low`, `bare-max`,
 * `bare-xhigh` for reasoning effort variants).
 */
function isHarnessHead(part: string): boolean {
  if (HARNESS_NAMES.has(part)) return true;
  return /^bare-[a-z0-9]+$/.test(part);
}

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
    if (i === 0 && isHarnessHead(p)) {
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
  const fpHarness = meta.fingerprint.harness;
  const isIter = fpHarness.kind === "bare" && !!fpHarness.iteration;
  if (isIter && headPart) {
    // For iter runs the head (`iter-png-2`) is the visible label and the
    // group slug (`iter-png`) drives the href so all chain steps land on one
    // page.
    out.push({
      kind: "harness",
      label: headPart,
      href: `/harnesses/${harnessGroupSlug(meta)}`,
    });
  } else if (headPart && isHarnessHead(headPart)) {
    out.push({ kind: "harness", label: headPart });
  } else {
    out.push({ kind: "harness", label: meta.harness.kind });
  }
  return out;
}

/**
 * Extract a reasoning-effort variant tag from a `bare-<variant>/...` matrixId.
 * Returns null for the plain `bare/...` (= provider default) and for non-bare
 * heads. Useful to label effort-variant runs as "low" / "max" / "xhigh" etc.
 */
export function effortVariantOf(meta: RunMeta): string | null {
  const head = meta.matrixId.split("/")[0];
  if (!head) return null;
  const m = head.match(/^bare-([a-z0-9]+)$/);
  return m ? m[1]! : null;
}

/**
 * Strip a date snapshot suffix (`-YYYYMMDD` / `-YYYY-MM-DD`) so model-family
 * matchers can be written against the alias name.
 */
function modelBaseName(model: string): string {
  return model.replace(/-\d{4}-\d{2}-\d{2}$/, "").replace(/-\d{8}$/, "");
}

/**
 * Provider-default reasoning effort for models that support effort. Returns
 * null for models without effort knob (Sonnet 4.5, Haiku 4.5, gpt-4.1, etc.)
 * or providers we haven't modeled yet (Gemini).
 */
function defaultEffortFor(
  provider: string | null | undefined,
  model: string | null | undefined,
): string | null {
  if (!provider || !model) return null;
  const base = modelBaseName(model);
  if (provider === "anthropic") {
    // Opus 4.5+ / Sonnet 4.6+ accept `output_config.effort` and default to "high".
    if (/^claude-opus-4-([5-9]|\d{2,})/.test(base)) return "high";
    if (/^claude-sonnet-4-6$/.test(base)) return "high";
    if (/^claude-sonnet-4-([7-9]|\d{2,})/.test(base)) return "high";
    return null;
  }
  if (provider === "openai") {
    // gpt-5 family + reasoning o-series default to "medium".
    if (/^gpt-5(\.\d+)?(-mini|-nano|-pro)?$/.test(base)) return "medium";
    if (/^o3(-mini|-pro)?$/.test(base)) return "medium";
    if (/^o4-mini$/.test(base)) return "medium";
    return null;
  }
  // TODO: Gemini's `thinkingConfig.thinkingBudget` is a different axis (token
  // budget, not symbolic effort levels) — not modeled in this helper yet.
  return null;
}

/**
 * Provider-default thinking mode for Anthropic models that take a
 * `thinking` parameter. Returns null when the model doesn't have a
 * "thinking" axis distinct from effort (OpenAI, Gemini are handled
 * separately or not at all).
 */
function defaultThinkingFor(
  provider: string | null | undefined,
  model: string | null | undefined,
): string | null {
  if (provider !== "anthropic" || !model) return null;
  const base = modelBaseName(model);
  // Adaptive thinking is the default on Opus 4.6+/Sonnet 4.6+.
  if (/^claude-opus-4-([6-9]|\d{2,})$/.test(base)) return "adaptive";
  if (/^claude-sonnet-4-([6-9]|\d{2,})$/.test(base)) return "adaptive";
  // Older Anthropic supports thinking via `enabled+budget_tokens` only when
  // explicitly opted in. Default behaviour without `thinking` is "off".
  if (/^claude-(opus|sonnet|haiku)-/.test(base)) return "off";
  return null;
}

/**
 * Compute the effective \"thinking\" mode for an Anthropic run. Returns:
 *   - { value: "adaptive", isDefault: true }   on Opus 4.6+/Sonnet 4.6+ default
 *   - { value: "off",      isDefault: ... }     when thinking is disabled
 *   - { value: "adaptive", isDefault: false }  when explicitly adaptive
 *   - { value: "enabled-<N>", isDefault: false } for legacy budget mode
 * Returns null for non-Anthropic providers (OpenAI subsumes thinking into
 * effort; Gemini's thinkingBudget is a separate axis we don't model here).
 */
export function thinkingInfoFor(
  meta: RunMeta,
): { value: string; isDefault: boolean } | null {
  if (meta.provider !== "anthropic") return null;
  const fpHarness = meta.fingerprint.harness;
  if (fpHarness.kind !== "bare") return null;
  const opts = (fpHarness.modelOptions ?? {}) as Record<string, unknown>;
  const explicit =
    typeof opts["thinking"] === "object" && opts["thinking"] !== null
      ? (opts["thinking"] as Record<string, unknown>)
      : undefined;
  if (explicit) {
    const t = explicit["type"];
    if (t === "disabled") return { value: "off", isDefault: false };
    if (t === "adaptive") return { value: "adaptive", isDefault: false };
    if (t === "enabled") {
      const n = explicit["budget_tokens"];
      const tag = typeof n === "number" ? `enabled-${n}` : "enabled";
      return { value: tag, isDefault: false };
    }
  }
  const def = defaultThinkingFor(meta.provider, meta.model);
  return def ? { value: def, isDefault: true } : null;
}

/**
 * Compute the effective reasoning-effort value for a run, plus whether the
 * value comes from the provider default (no explicit `modelOptions.effort`).
 * Returns null when the model doesn't support an effort knob at all.
 */
export function effortInfoFor(
  meta: RunMeta,
): { value: string; isDefault: boolean } | null {
  const fpHarness = meta.fingerprint.harness;
  if (fpHarness.kind !== "bare") return null;
  const opts = (fpHarness.modelOptions ?? {}) as Record<string, unknown>;
  if (meta.provider === "anthropic") {
    const explicit =
      typeof opts["output_config"] === "object" && opts["output_config"] !== null
        ? ((opts["output_config"] as Record<string, unknown>)["effort"] as
            | string
            | undefined)
        : undefined;
    if (explicit) return { value: explicit, isDefault: false };
    const def = defaultEffortFor(meta.provider, meta.model);
    return def ? { value: def, isDefault: true } : null;
  }
  if (meta.provider === "openai") {
    const explicit =
      typeof opts["reasoning"] === "object" && opts["reasoning"] !== null
        ? ((opts["reasoning"] as Record<string, unknown>)["effort"] as
            | string
            | undefined)
        : undefined;
    if (explicit) return { value: explicit, isDefault: false };
    const def = defaultEffortFor(meta.provider, meta.model);
    return def ? { value: def, isDefault: true } : null;
  }
  return null;
}

/**
 * Group runs into harness "buckets" for the /harnesses/[id]/ index.
 *
 *   single-shot bare                 → "bare"
 *   bare iteration step              → matrixId 先頭セグメントから末尾の "-N" を
 *                                      削った文字列(`iter-png-2` → `iter-png`)
 *   external-agent                   → "external-agent"
 *
 * Slug は URL に入る都合で安全文字のみで構成される値を返す。
 */
export function harnessGroupSlug(meta: RunMeta): string {
  if (meta.harness.kind === "external-agent") return "external-agent";
  // bare: 単発 vs iter step
  const fpHarness = meta.fingerprint.harness;
  const isIter = fpHarness.kind === "bare" && !!fpHarness.iteration;
  if (!isIter) return "bare";
  const prefix = meta.matrixId.split("/")[0] ?? "";
  return prefix.replace(/-\d+$/, "");
}

/**
 * Walk meta.fingerprint.harness.iterateFrom along the chain backwards using
 * a matrixId → fingerprint lookup. Returns 0 for chain heads / single-shot.
 */
export function chainDepthFor(
  matrixId: string,
  fpByMatrixId: Map<string, RunMeta["fingerprint"]>,
): number {
  const seen = new Set<string>();
  let depth = 0;
  let cur: string | undefined = matrixId;
  while (cur && !seen.has(cur)) {
    seen.add(cur);
    const fp = fpByMatrixId.get(cur);
    if (!fp || fp.harness.kind !== "bare" || !fp.harness.iterateFrom) break;
    depth += 1;
    cur = fp.harness.iterateFrom;
  }
  return depth;
}

/** Walk back to the chain root matrixId (returns input for non-iter inputs). */
export function chainRootMatrixId(
  matrixId: string,
  fpByMatrixId: Map<string, RunMeta["fingerprint"]>,
): string {
  const seen = new Set<string>();
  let cur = matrixId;
  while (!seen.has(cur)) {
    seen.add(cur);
    const fp = fpByMatrixId.get(cur);
    if (!fp || fp.harness.kind !== "bare" || !fp.harness.iterateFrom) {
      return cur;
    }
    cur = fp.harness.iterateFrom;
  }
  return cur;
}

/** Build matrixId → first-seen fingerprint map from a runs collection. */
export function fingerprintByMatrixId(
  runs: Iterable<{ meta: RunMeta }>,
): Map<string, RunMeta["fingerprint"]> {
  const out = new Map<string, RunMeta["fingerprint"]>();
  for (const r of runs) {
    if (!out.has(r.meta.matrixId)) out.set(r.meta.matrixId, r.meta.fingerprint);
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
