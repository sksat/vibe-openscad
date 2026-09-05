import { resolve } from "node:path";
import { resolveModel } from "@vibe-openscad/runners/src/models.js";
import { computeCostUsd } from "@vibe-openscad/runners/src/pricing.js";
import type { RunMeta, Task } from "@vibe-openscad/runners/src/schema.js";
import { loadDataset } from "./results.js";

/**
 * 命名規約: 末尾 `-self-hosted` が付く provider はセルフホスト系。将来
 * `anthropic-self-hosted` / `google-self-hosted` が増えても自動で同じ
 * 判定ロジックが効く。
 */
const SELF_HOSTED_SUFFIX = "-self-hosted";
export function isSelfHostedProvider(provider: string): boolean {
  return provider.endsWith(SELF_HOSTED_SUFFIX);
}
/** `openai-self-hosted` → `openai` のように suffix を剥がす(self-hosted
 *  でなければそのまま)。 */
function selfHostedBase(provider: string): string {
  return isSelfHostedProvider(provider)
    ? provider.slice(0, -SELF_HOSTED_SUFFIX.length)
    : provider;
}

/**
 * Provider 文字列(`anthropic` / `openai` / `openai-self-hosted` / `google`
 * 等)を「人間に見せたい label」に変換。
 *  - `<vendor>-self-hosted` → "<vendor> (self-hosted)"
 *  - その他はそのまま返す
 */
export function providerDisplayLabel(provider: string): string {
  if (isSelfHostedProvider(provider)) {
    return `${selfHostedBase(provider)} (self-hosted)`;
  }
  return provider;
}

/**
 * 一覧グルーピング用の「論理 provider キー」を返す。
 *
 * セルフホスト run の `meta.provider` は API protocol を表すだけで、実際に
 * 動かしているモデルの vendor とは独立している(例: LM Studio = `openai-
 * self-hosted` 上で gemma を動かすケース)。素直に `meta.provider` で
 * グルーピングすると `openai-self-hosted` バケツに gemma が紛れて見えるので、
 * セルフホストのときは model id から vendor を推定して
 * `<vendor>-self-hosted` を返す。推定できなければ `self-hosted`。
 *
 * 非セルフホストではそのまま `meta.provider` を返す。
 */
export function runGroupProvider(meta: RunMeta): string {
  const provider = meta.provider ?? "unknown";
  if (!isSelfHostedProvider(provider)) return provider;
  if (meta.model) {
    for (const s of parseModelLabel(meta.model)) {
      if (s.kind === "vendor" && s.vendor) {
        const v = s.vendor;
        const base = v === "claude" ? "anthropic" : v === "gemini" ? "google" : v;
        return `${base}-self-hosted`;
      }
    }
  }
  return "self-hosted";
}

/**
 * Provider 文字列を VendorIcon の vendor プロパティに対応付ける。
 * cloud product 用のロゴ(Claude / Gemini / OpenAI)を優先する。
 * `<vendor>-self-hosted` は同じロゴ(self-host = 同じモデル提供者の
 * 重みを動かしているケースが多い)。
 */
export function providerVendor(
  provider: string,
): "claude" | "gemini" | "openai" | undefined {
  const base = selfHostedBase(provider);
  switch (base) {
    case "anthropic":
      return "claude";
    case "openai":
      return "openai";
    case "google":
      return "gemini";
    default:
      return undefined;
  }
}

/**
 * LM Studio / Ollama の `publisher` 文字列を VendorIcon の vendor キーに
 * 対応付ける。publisher は「重み配布元」(社名・コミュニティ名)なので
 * cloud product (Gemini, Claude) ではなく **会社・組織** のロゴを使う:
 *
 *   - `openai`              → openai (custom inline)
 *   - `google`              → google (Gemma 等は Google 名義)
 *   - `anthropic`           → anthropic
 *   - `qwen` / `alibaba`    → qwen
 *
 * `lmstudio-community` / `unsloth` / `HauhauCS` / `ggml-org` 等は
 * simple-icons に無いので undefined(テキストのみ表示)。
 */
export function publisherVendor(
  publisher: string,
):
  | "claude"
  | "anthropic"
  | "gemini"
  | "google"
  | "openai"
  | "nvidia"
  | "qwen"
  | "huggingface"
  | undefined {
  switch (publisher.toLowerCase()) {
    case "openai":
      return "openai";
    case "google":
      return "google";
    case "anthropic":
      return "anthropic";
    case "nvidia":
      return "nvidia";
    case "qwen":
    case "alibaba":
      return "qwen";
    case "huggingface":
    case "hugging-face":
      return "huggingface";
    default:
      return undefined;
  }
}

/**
 * モデル id を「並べたい順」のキーに変換する。一覧表示で
 *   Claude: opus > sonnet > haiku、新しい version が先
 *   OpenAI: gpt-5.5 > gpt-5.4 > gpt-5 > gpt-4.x、 mini/nano は後ろ、o3 / o4 系は別バケツ
 *   Gemini: pro > flash > flash-lite、新しい version が先
 * の順になるようにする。`compareModelsByRank` を sort callback として使う。
 *
 * 戻り値は [familyRank, -version, sizeRank, model] の数列。タイブレーク
 * 用に最後に model 文字列を入れて辞書順 fallback。
 */
export function modelSortKey(model: string): [number, number, number, string] {
  // カタログの明示宣言が最優先。命名規則から外れる id(gpt-5.6-sol のように
  // 世代とティアが別語彙のもの)は、下の正規表現が「それらしく」拾ってしまう
  // ので、宣言があるならパターン推論より先に効かせる。
  const declared = resolveModel(model)?.sort;
  if (declared) {
    return [declared.family, -declared.version, declared.size ?? 0, model];
  }
  // Anthropic: claude-{fable|opus|sonnet|haiku}-X[-Y][-YYYYMMDD]
  // Fable(Opus の上のティア)は minor を持たない(claude-fable-5)。
  // minor は 1-3 桁に限定して 8 桁の date suffix と区別する。
  let m = /^claude-(fable|opus|sonnet|haiku)-(\d+)(?:-(\d{1,3}))?(?:-\d{8})?$/.exec(
    model,
  );
  if (m) {
    const familyMap: Record<string, number> = {
      fable: 0,
      opus: 1,
      sonnet: 2,
      haiku: 3,
    };
    const major = Number(m[2]);
    const minor = m[3] ? Number(m[3]) : 0;
    return [familyMap[m[1]!] ?? 99, -(major * 1000 + minor), 0, model];
  }
  // Gemini: gemini-X[.Y]-{pro|flash-lite|flash}[-...]
  // flash-lite を flash より先に検査(部分一致を避ける)。
  m = /^gemini-(\d+)(?:\.(\d+))?-(pro|flash-lite|flash)/.exec(model);
  if (m) {
    const familyMap: Record<string, number> = {
      pro: 0,
      flash: 1,
      "flash-lite": 2,
    };
    const major = Number(m[1]);
    const minor = m[2] ? Number(m[2]) : 0;
    return [familyMap[m[3]!] ?? 99, -(major * 1000 + minor), 0, model];
  }
  // OpenAI gpt-X[.Y][-suffix...] (codex / mini / nano / pro)。
  m = /^gpt-(\d+)(?:\.(\d+))?/.exec(model);
  if (m) {
    const major = Number(m[1]);
    const minor = m[2] ? Number(m[2]) : 0;
    const isCodex = /-codex(\b|-)/.test(model);
    let size = 0;
    if (/-pro(\b|-)/.test(model)) size = -1;
    else if (/-mini(\b|-)/.test(model)) size = 1;
    else if (/-nano(\b|-)/.test(model)) size = 2;
    // codex ファミリは別塊として後ろに(version 比較は同等)。
    const family = isCodex ? 1 : 0;
    return [family, -(major * 1000 + minor), size, model];
  }
  // OpenAI o-series reasoning: o3 / o3-pro / o4-mini など。
  m = /^o(\d+)/.exec(model);
  if (m) {
    const major = Number(m[1]);
    let size = 0;
    if (/-pro(\b|-)/.test(model)) size = -1;
    else if (/-mini(\b|-)/.test(model)) size = 1;
    return [2, -major * 1000, size, model];
  }
  // 該当なし: 末尾扱いで辞書順。
  return [99, 0, 0, model];
}

export function compareModelsByRank(a: string, b: string): number {
  const ka = modelSortKey(a);
  const kb = modelSortKey(b);
  for (let i = 0; i < 4; i++) {
    const va = ka[i] as number | string;
    const vb = kb[i] as number | string;
    if (va === vb) continue;
    if (typeof va === "number" && typeof vb === "number") return va - vb;
    return String(va).localeCompare(String(vb));
  }
  return 0;
}

/**
 * task の URL に使う slug を返す。
 * - YAML で `slug:` を明示していればそれを使う
 * - 無ければ `id` から `tier-N-` prefix を剥がす(`tier-1-mug` → `mug`)
 *
 * URL に tier 番号を入れたくないが、内部 id は signature fingerprint に
 * 効くので不用意に変えたくない、というポリシーを反映。slug 衝突は
 * `taskSlugById` 構築時に検出する(複数 task が同 slug にマップする
 * 構成は無効)。
 */
export function taskSlug(task: Pick<Task, "id" | "slug">): string {
  if (task.slug) return task.slug;
  return task.id.replace(/^tier-\d+-/, "");
}

/**
 * 全 task について `taskId → slug` の map を返す。URL 生成側がこれを
 * 持っておけば、`meta.taskId` だけ持っている文脈(Run 詳細など)からも
 * 即 slug を引ける。同時に slug 衝突を assert する。
 */
export function buildTaskSlugMap(
  tasks: Pick<Task, "id" | "slug">[],
): Map<string, string> {
  const map = new Map<string, string>();
  const reverse = new Map<string, string>();
  for (const t of tasks) {
    const s = taskSlug(t);
    const collision = reverse.get(s);
    if (collision && collision !== t.id) {
      throw new Error(
        `slug "${s}" maps to multiple task ids: ${collision}, ${t.id}. Set explicit slug: in YAML to disambiguate.`,
      );
    }
    map.set(t.id, s);
    reverse.set(s, t.id);
  }
  return map;
}

/**
 * Locate the repo root from the web/ package and load the dataset.
 *
 * `astro dev` and `astro build` both run with cwd=web/, so the repo root is
 * one directory up. We avoid `import.meta.dirname` because Astro bundles the
 * page module to `web/dist/.prerender/chunks/` at build time and the
 * relative path from there points into dist/, not the repo.
 */
export async function getDataset() {
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
  vendor?: "claude" | "gemini" | "openai" | "nvidia" | "qwen";
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
 * `bare-xhigh` for reasoning effort variants, `bare-think-off` /
 * `bare-think-adaptive` for thinking variants).
 */
function isHarnessHead(part: string): boolean {
  if (HARNESS_NAMES.has(part)) return true;
  return /^bare(-[a-z0-9]+)+$/.test(part);
}

/**
 * `publisher/model` 形式のセルフホスト id から vendor アイコンキーを引く。
 * publisher は「重み配布元」なので、`google/gemma-*` は Gemini ロゴになる。
 */
function slashedPublisherVendor(
  modelStr: string,
): MatrixSegment["vendor"] | undefined {
  const m = modelStr.match(/^([a-z][\w-]*)\/(.+)$/i);
  if (!m) return undefined;
  switch (m[1]!.toLowerCase()) {
    case "openai":
      return "openai";
    case "anthropic":
      return "claude";
    case "google":
      return "gemini";
    case "nvidia":
      return "nvidia";
    default:
      return undefined;
  }
}

/** Parse one model id string into vendor + model badges (or fall through). */
export function parseModelLabel(modelStr: string): MatrixSegment[] {
  // カタログに表示名の宣言があればそれを使う(vendor バッジは provider から
  // 引く)。下のパターン群は「素直な id」を賄うためのもので、外れる id を
  // 誤って拾わないよう宣言を先に見る。
  const declared = resolveModel(modelStr);
  if (declared?.label) {
    // `google/gemma-4-e2b` のようなセルフホスト id では provider
    // (`openai-self-hosted` = API プロトコル)ではなく **publisher** が
    // vendor。provider から引くと Google のモデルが OpenAI ロゴになる。
    const vendor =
      slashedPublisherVendor(modelStr) ?? providerVendor(declared.provider);
    if (vendor) {
      // バッジの文字は publisher(`google`)、アイコンキーは vendor
      // (`gemini`)。両者は一致しないので使い分ける。
      const publisher = modelStr.match(/^([a-z][\w-]*)\//i)?.[1]?.toLowerCase();
      return [
        { kind: "vendor", label: publisher ?? vendor, vendor },
        { kind: "model", label: declared.label, title: modelStr, vendor },
      ];
    }
    return [{ kind: "model", label: declared.label, title: modelStr }];
  }

  // Anthropic model: claude-(fable|opus|sonnet|haiku)-MAJOR[-MINOR][-YYYYMMDD]
  // Minor is constrained to 1-3 digits to disambiguate from an 8-digit date
  // (e.g. claude-opus-4-20250514 has no minor, just major + date).
  // Fable carries only a major version (claude-fable-5).
  const claude = modelStr.match(
    /^claude-(fable|opus|sonnet|haiku)-(\d+)(?:-(\d{1,3}))?(?:-(\d{8}))?$/,
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

  // OpenAI GPT codex: gpt-MAJOR[.MINOR]-codex[-(max|mini)]
  const gptCodex = modelStr.match(
    /^gpt-(\d+(?:\.\d+)?)-codex(?:-(max|mini))?$/,
  );
  if (gptCodex) {
    const ver = gptCodex[1];
    const label = `gpt ${ver} codex${gptCodex[2] ? ` ${gptCodex[2]}` : ""}`;
    return [
      { kind: "vendor", label: "openai", vendor: "openai" },
      { kind: "model", label, title: modelStr, vendor: "openai" },
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

  // Qwen 系(bare 形式): `qwen3-8b` / `qwen3-0.6b` / `qwen3-32b` 等。
  // 厳密な publisher prefix は無いが community 配布の qwen3-* は普通に
  // 出回っているので 1 級 vendor 扱い。
  const qwen3 = modelStr.match(/^(qwen[23](?:\.\d+)?)-(.+)$/i);
  if (qwen3) {
    return [
      { kind: "vendor", label: "qwen", vendor: "qwen" },
      { kind: "model", label: modelStr, title: modelStr, vendor: "qwen" },
    ];
  }

  // セルフホスト系の publisher 接頭辞付きモデル(LM Studio / Ollama):
  //   openai/gpt-oss-20b、qwen/qwen3.6-27b、google/gemma-3-27b 等
  // 既知 publisher なら vendor logo と組み合わせて出し、その他は単一の
  // model badge にする。どちらも `kind: "model"` を返してクリック可能に
  // する(行き先は /models/<encodeURIComponent(modelStr)>)。
  const slashed = modelStr.match(/^([a-z][\w-]*)\/(.+)$/i);
  if (slashed) {
    const publisher = slashed[1]!.toLowerCase();
    const localModel = slashed[2]!;
    const vendor = slashedPublisherVendor(modelStr);
    if (vendor) {
      return [
        { kind: "vendor", label: publisher, vendor },
        { kind: "model", label: localModel, title: modelStr, vendor },
      ];
    }
    return [{ kind: "model", label: modelStr, title: modelStr }];
  }

  return [{ kind: "other", label: modelStr }];
}

/**
 * Compact human-readable label for a model id. Used in breadcrumbs and
 * places where the full canonical id (with date suffix / `-preview`) is
 * needlessly verbose. Convention:
 *
 *   claude-opus-4-7              → "claude opus 4.7"
 *   gpt-5.4-mini-2026-03-17      → "gpt 5.4 mini"
 *   gpt-5.1-codex-max            → "gpt 5.1 codex max"
 *   o4-mini-2025-04-16           → "o4 mini"
 *   gemini-3.1-pro-preview       → "gemini 3.1 pro"
 *
 * Returns the input unchanged when no pattern matches (safe fallback).
 */
export function shortModelLabel(model: string): string {
  if (!model) return model;
  const declared = resolveModel(model)?.label;
  if (declared) return declared;
  const claude = model.match(
    /^claude-(fable|opus|sonnet|haiku)-(\d+)(?:-(\d{1,3}))?(?:-\d{8})?$/,
  );
  if (claude) {
    const ver = claude[3] ? `${claude[2]}.${claude[3]}` : claude[2];
    return `claude ${claude[1]} ${ver}`;
  }
  const gptCodex = model.match(
    /^gpt-(\d+(?:\.\d+)?)-codex(?:-(max|mini))?$/,
  );
  if (gptCodex) {
    return `gpt ${gptCodex[1]} codex${gptCodex[2] ? ` ${gptCodex[2]}` : ""}`;
  }
  const gpt = model.match(
    /^gpt-(\d+(?:\.\d+)?)(?:-(mini|nano|pro|turbo))?(?:-(\d{4}-\d{2}-\d{2}|preview|latest))?$/,
  );
  if (gpt) {
    return `gpt ${gpt[1]}${gpt[2] ? ` ${gpt[2]}` : ""}`;
  }
  const oseries = model.match(
    /^(o\d+)(?:-(mini|pro|preview))?(?:-\d{4}-\d{2}-\d{2})?$/,
  );
  if (oseries) {
    return `${oseries[1]}${oseries[2] ? ` ${oseries[2]}` : ""}`;
  }
  const gemini = model.match(
    /^gemini-(\d+(?:\.\d+)?)-(pro|flash-lite|flash)(?:-(?:preview(?:-[\w-]+)?|\d+|latest|exp[\w-]*))?$/,
  );
  if (gemini) {
    return `gemini ${gemini[1]} ${gemini[2]}`;
  }
  return model;
}

/**
 * Vendor icon key for a model id (`claude` / `gemini` / `openai` / `nvidia` /
 * `qwen`), or undefined when none matches. Derived from the same parser the
 * badges use, so self-hosted `google/gemma-3-27b` resolves to its weight
 * publisher's icon. Used by the leaderboard's model cell.
 */
export function modelVendorIcon(
  model: string,
): "claude" | "gemini" | "openai" | "nvidia" | "qwen" | undefined {
  for (const s of parseModelLabel(model)) {
    if (s.vendor) return s.vendor;
  }
  return undefined;
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
  if (meta.model) {
    const segs = parseModelLabel(meta.model);
    // セルフホスト run の vendor badge は「<vendor> (self-hosted)」と
    // 表記して cloud との区別を一目で付けられるようにする。
    // ただし provider 文字列の base("openai-self-hosted" → "openai")は
    // API protocol を表すだけで、実際の model vendor とは独立。
    // 例: LM Studio (= openai-self-hosted) で gemma を動かすと
    //   model = google/gemma-3-27b → vendor = "google" (or "gemini")
    // なので「openai (self-hosted)」と書くと嘘になる。model 自身の
    // vendor label に "(self-hosted)" を付加するだけにする。
    if (meta.provider && isSelfHostedProvider(meta.provider)) {
      for (const s of segs) {
        if (s.kind === "vendor") {
          s.label = `${s.label} (self-hosted)`;
        }
      }
    }
    out.push(...segs);
  }
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
 * Provider-default reasoning effort。値は models.yml(モデルカタログ)側に
 * あり、ここは参照するだけ。effort ノブを持たないモデル(Sonnet 4.5 /
 * Haiku 4.5 / gpt-4.1 等)はカタログで `effort: null` と宣言されている。
 */
function defaultEffortFor(
  provider: string | null | undefined,
  model: string | null | undefined,
): string | null {
  if (!provider || !model) return null;
  return resolveModel(model, provider)?.effort ?? null;
}

/**
 * Provider-default thinking mode。同じく models.yml 由来。thinking 軸を
 * 持たない provider / モデル(OpenAI は thinking を effort に内包する)は
 * カタログに `thinking` を宣言しないので null になる。
 */
function defaultThinkingFor(
  provider: string | null | undefined,
  model: string | null | undefined,
): string | null {
  if (!provider || !model) return null;
  return resolveModel(model, provider)?.thinking ?? null;
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
  const fpHarness = meta.fingerprint.harness;
  if (fpHarness.kind !== "bare") return null;
  const opts = (fpHarness.modelOptions ?? {}) as Record<string, unknown>;
  if (meta.provider === "anthropic") {
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
  if (meta.provider === "google") {
    const config =
      typeof opts["config"] === "object" && opts["config"] !== null
        ? (opts["config"] as Record<string, unknown>)
        : undefined;
    const tConfig =
      config && typeof config["thinkingConfig"] === "object" &&
      config["thinkingConfig"] !== null
        ? (config["thinkingConfig"] as Record<string, unknown>)
        : undefined;
    if (tConfig && tConfig["thinkingBudget"] !== undefined) {
      const b = tConfig["thinkingBudget"];
      if (b === 0) return { value: "off", isDefault: false };
      if (b === -1) return { value: "dynamic", isDefault: false };
      if (typeof b === "number") {
        return { value: `budget-${b}`, isDefault: false };
      }
    }
    const def = defaultThinkingFor(meta.provider, meta.model);
    return def ? { value: def, isDefault: true } : null;
  }
  return null;
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
