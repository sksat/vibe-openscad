import { createHash } from "node:crypto";
import { canonicalJson } from "./canonical.js";
import type { Fingerprint } from "./schema.js";

/**
 * Fingerprint から決定的な signature(sha256 hex)を計算する。
 *
 * - 配列の順序を意味として持たないフィールド(allowedTools)はソートして正規化する
 * - それ以外は canonicalJson に任せる
 */
export function computeSignature(fp: Fingerprint): string {
  const normalized = normalize(fp);
  return createHash("sha256").update(canonicalJson(normalized)).digest("hex");
}

export function shortSignature(sig: string): string {
  return sig.slice(0, 12);
}

function normalize(fp: Fingerprint): Fingerprint {
  if (fp.harness.kind === "external-agent") {
    return {
      ...fp,
      harness: {
        ...fp.harness,
        allowedTools: [...fp.harness.allowedTools].sort(),
      },
    };
  }
  return fp;
}
