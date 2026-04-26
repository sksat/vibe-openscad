/**
 * Extract the OpenSCAD source from an LLM response.
 *
 * Preference order:
 *   1. ```openscad ... ```  (explicit)
 *   2. ```scad ... ```      (alias)
 *   3. ``` ... ```          (unlabeled, last resort)
 *
 * Returns null when no non-empty code block is found.
 */
export function extractScad(text: string): string | null {
  const labeled = matchFenced(text, /openscad|scad/i);
  if (labeled !== null) return labeled;
  return matchFenced(text, null);
}

function matchFenced(text: string, label: RegExp | null): string | null {
  const fence = /(^|\n)```([^\n]*)\n([\s\S]*?)\n```(?=\n|$)/g;
  let m: RegExpExecArray | null;
  while ((m = fence.exec(text)) !== null) {
    const tag = (m[2] ?? "").trim();
    const body = (m[3] ?? "").trim();
    const matchesLabel = label === null ? tag === "" : label.test(tag);
    if (matchesLabel && body.length > 0) {
      return body;
    }
  }
  return null;
}
