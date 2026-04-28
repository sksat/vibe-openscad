/**
 * cargo-test 風の出力を組み立てる小さなユーティリティ。
 *
 * 提供するのは「文字列を返す」関数のみ。実際の標準出力への書き出しは呼び出し側の責務。
 */

const ANSI = {
  reset: "\x1b[0m",
  bold: "\x1b[1m",
  green: "\x1b[32m",
  red: "\x1b[31m",
  yellow: "\x1b[33m",
  cyan: "\x1b[36m",
  dim: "\x1b[2m",
};

export interface ColorOptions {
  color?: boolean;
}

function paint(s: string, code: string, opts: ColorOptions): string {
  return opts.color ? `${code}${s}${ANSI.reset}` : s;
}

export function header(n: number, noun: string): string {
  return `running ${n} ${noun}`;
}

export type StatusToken =
  | "ok"
  | "FAILED"
  | "skipped"
  | "missing"
  | "stale"
  | "up-to-date"
  | "blocked";

export interface ItemLine {
  verb: string; // "plan" | "bench" | etc.
  name: string;
  status: StatusToken;
  hint?: string; // e.g. "render_error", "12.3s 100in/200out"
}

export function itemLine(item: ItemLine, opts: ColorOptions = {}): string {
  const tail = item.hint ? `${item.status} (${item.hint})` : item.status;
  const colored = paint(tail, statusColor(item.status), opts);
  return `${item.verb} ${item.name} ... ${colored}`;
}

function statusColor(s: StatusToken): string {
  switch (s) {
    case "ok":
    case "up-to-date":
      return ANSI.green;
    case "FAILED":
      return ANSI.red;
    case "missing":
      return ANSI.yellow;
    case "stale":
      return ANSI.yellow;
    case "skipped":
    case "blocked":
      return ANSI.dim;
  }
}

export type Summary =
  | {
      kind: "bench";
      ok: boolean;
      counts: {
        passed: number;
        failed: number;
        skipped: number;
        blocked?: number;
      };
      durationMs: number;
    }
  | {
      kind: "plan";
      counts: {
        missing: number;
        stale: number;
        upToDate: number;
        blocked?: number;
      };
    };

export function summary(s: Summary, opts: ColorOptions = {}): string {
  if (s.kind === "bench") {
    const verdict = s.ok
      ? paint("ok", ANSI.green, opts)
      : paint("FAILED", ANSI.red, opts);
    const secs = (s.durationMs / 1000).toFixed(2);
    const blocked = s.counts.blocked ?? 0;
    const tail = blocked > 0 ? `; ${blocked} blocked` : "";
    return `bench result: ${verdict}. ${s.counts.passed} passed; ${s.counts.failed} failed; ${s.counts.skipped} skipped${tail}; finished in ${secs}s`;
  }
  const blocked = s.counts.blocked ?? 0;
  const tail = blocked > 0 ? `; ${blocked} blocked` : "";
  return `plan result: ${s.counts.missing} missing; ${s.counts.stale} stale; ${s.counts.upToDate} up-to-date${tail}`;
}

export interface Failure {
  name: string;
  detail: string;
}

export function failuresSection(
  failures: Failure[],
  opts: ColorOptions = {},
): string {
  if (failures.length === 0) return "";
  const head = paint("failures:", ANSI.red, opts);
  const lines: string[] = ["", head, ""];
  for (const f of failures) {
    lines.push(`---- ${f.name} ----`);
    lines.push(f.detail);
    lines.push("");
  }
  lines.push(head);
  for (const f of failures) {
    lines.push(`    ${f.name}`);
  }
  lines.push("");
  return lines.join("\n");
}
