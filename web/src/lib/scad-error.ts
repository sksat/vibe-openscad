/**
 * Parse OpenSCAD stderr / harness error message into per-line annotations
 * suitable for VSCode-style red squiggle overlay on the SCAD source view.
 *
 * Examples we handle:
 *   "ERROR: Parser error: syntax error in file ../../tmp/.../input.scad, line 70"
 *   "TRACE: call of 'cylinder(...)' in file input.scad, line 80"
 *   "ERROR: foo in file '/tmp/render-X/input.scad', line 12"
 *
 * Multiple annotations on the same line collapse into one entry whose
 * `message` is a newline-joined union (so the hover tooltip can show all).
 */
export interface ScadErrorAnnotation {
  /** 1-based line number in the SCAD source. */
  line: number;
  /** Human-readable message (without the file/line trailer). */
  message: string;
}

const LINE_REGEX =
  /^(.*?)\s+in file (?:'?[^,'\n]*\binput\.scad'?|input\.scad),\s*line\s+(\d+)/i;

export function parseScadErrors(
  raw: string | null | undefined,
): ScadErrorAnnotation[] {
  if (!raw) return [];
  const byLine = new Map<number, string[]>();
  for (const lineRaw of raw.split(/\r?\n/)) {
    const m = lineRaw.match(LINE_REGEX);
    if (!m) continue;
    const before = (m[1] ?? "").trim();
    const ln = Number(m[2]);
    if (!Number.isFinite(ln) || ln <= 0) continue;
    // Strip leading wrapper noise like "openscad stl render failed (exit 1):"
    const cleaned = before.replace(/^openscad[^:]*:\s*/i, "").trim();
    const list = byLine.get(ln) ?? [];
    list.push(cleaned);
    byLine.set(ln, list);
  }
  return [...byLine.entries()].map(([line, msgs]) => ({
    line,
    message: msgs.join("\n"),
  }));
}
