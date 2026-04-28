import { diffLines } from "diff";

export type DiffLineType = "context" | "added" | "removed";
export interface DiffLine {
  type: DiffLineType;
  text: string;
}

/**
 * Line-level diff between two text blobs (typically SCAD files). Returns a
 * flat sequence of lines tagged context / added / removed. Trailing newlines
 * inside chunks are stripped so callers can render each line on its own row.
 */
export function lineDiff(before: string, after: string): DiffLine[] {
  const out: DiffLine[] = [];
  const parts = diffLines(before, after);
  for (const part of parts) {
    const type: DiffLineType = part.added
      ? "added"
      : part.removed
        ? "removed"
        : "context";
    // diffLines chunks include trailing newlines; split into individual
    // lines, drop trailing-empty caused by terminal "\n".
    const lines = part.value.split("\n");
    if (lines.length > 0 && lines[lines.length - 1] === "") {
      lines.pop();
    }
    for (const text of lines) {
      out.push({ type, text });
    }
  }
  return out;
}
