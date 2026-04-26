/**
 * Extract top-level variable declarations from OpenSCAD source so they
 * can be exposed as a Customizer-style parameter UI.
 *
 * Recognizes literal-valued assignments of numbers and booleans. Other
 * expressions are surfaced as `kind: "expr"` so callers can choose to
 * skip them (they aren't safely tweakable via a slider).
 *
 * Inside module bodies (any depth) assignments are ignored — they're
 * locals, not user-facing parameters. function() = ... declarations are
 * also skipped.
 *
 * Supports OpenSCAD Customizer-style range hints in trailing line comments:
 *   height = 100; // [10:200]
 *   wall = 4; // [1:0.5:8]
 */
export type ScadParameter =
  | {
      name: string;
      kind: "number";
      value: number;
      range?: { min: number; max: number; step?: number };
    }
  | {
      name: string;
      kind: "boolean";
      value: boolean;
    }
  | {
      name: string;
      kind: "expr";
      raw: string;
    };

export interface ExtractOptions {
  /** Include $-prefixed special variables ($fn, $fa, $fs). */
  includeSpecial?: boolean;
}

/** Strip line + block comments while remembering what was on each line. */
function stripComments(src: string): { code: string; trailing: string[] } {
  const trailing: string[] = [];
  const out: string[] = [];
  let i = 0;
  let inBlock = false;
  let line = "";
  let lineTrailing = "";
  while (i < src.length) {
    const ch = src[i]!;
    const next = src[i + 1] ?? "";
    if (inBlock) {
      if (ch === "*" && next === "/") {
        inBlock = false;
        i += 2;
      } else {
        i++;
      }
      continue;
    }
    if (ch === "/" && next === "*") {
      inBlock = true;
      i += 2;
      continue;
    }
    if (ch === "/" && next === "/") {
      // line comment runs to end of line
      let j = i + 2;
      while (j < src.length && src[j] !== "\n") j++;
      lineTrailing = src.slice(i, j);
      i = j;
      continue;
    }
    if (ch === "\n") {
      out.push(line);
      trailing.push(lineTrailing);
      line = "";
      lineTrailing = "";
      i++;
      continue;
    }
    line += ch;
    i++;
  }
  if (line.length > 0 || lineTrailing.length > 0) {
    out.push(line);
    trailing.push(lineTrailing);
  }
  return { code: out.join("\n"), trailing };
}

/** Walk top-level statements with brace tracking. */
function* topLevelStatements(
  code: string,
  trailing: string[],
): Generator<{ stmt: string; trailingComment: string }> {
  // Map character index → original line index, so we can fetch the trailing
  // comment that matches the line where the statement *ends*.
  let depth = 0;
  let buf = "";
  let stmtEndLine = 0;
  let curLine = 0;
  for (let i = 0; i < code.length; i++) {
    const ch = code[i]!;
    if (ch === "\n") curLine++;
    if (ch === "{" || ch === "[" || ch === "(") depth++;
    else if (ch === "}" || ch === "]" || ch === ")") depth = Math.max(0, depth - 1);
    buf += ch;
    if (depth === 0 && ch === ";") {
      stmtEndLine = curLine;
      yield { stmt: buf, trailingComment: trailing[stmtEndLine] ?? "" };
      buf = "";
    }
  }
}

const ASSIGN_RE = /^\s*(\$?[A-Za-z_][A-Za-z0-9_]*)\s*=\s*([\s\S]+?)\s*;\s*$/;
const NUMBER_RE = /^-?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?$/;

function parseRangeHint(comment: string): {
  min: number;
  max: number;
  step?: number;
} | null {
  // // [min:max] or // [min:step:max]
  const m = comment.match(/\[\s*(-?\d+(?:\.\d+)?)\s*:\s*(-?\d+(?:\.\d+)?)\s*(?::\s*(-?\d+(?:\.\d+)?)\s*)?\]/);
  if (!m) return null;
  const a = Number(m[1]);
  const b = Number(m[2]);
  const c = m[3] !== undefined ? Number(m[3]) : null;
  if (c === null) return { min: a, max: b };
  return { min: a, step: b, max: c };
}

export function extractParameters(
  source: string,
  opts: ExtractOptions = {},
): ScadParameter[] {
  const { code, trailing } = stripComments(source);
  const params: ScadParameter[] = [];
  for (const { stmt, trailingComment } of topLevelStatements(code, trailing)) {
    const trimmed = stmt.trim();
    // Skip module/function declarations entirely.
    if (/^(module|function)\b/.test(trimmed)) continue;
    const m = trimmed.match(ASSIGN_RE);
    if (!m) continue;
    const name = m[1]!;
    const rawValue = m[2]!.trim();
    if (!opts.includeSpecial && name.startsWith("$")) continue;

    if (rawValue === "true" || rawValue === "false") {
      params.push({
        name,
        kind: "boolean",
        value: rawValue === "true",
      });
      continue;
    }
    if (NUMBER_RE.test(rawValue)) {
      const range = parseRangeHint(trailingComment);
      params.push({
        name,
        kind: "number",
        value: Number(rawValue),
        ...(range ? { range } : {}),
      });
      continue;
    }
    params.push({ name, kind: "expr", raw: rawValue });
  }
  return params;
}
