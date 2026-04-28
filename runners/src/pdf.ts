/**
 * PDF を取ってきて指定ページを PNG に切り出す薄いユーティリティ。
 * pdf-page harness が使う。
 *
 * - URL fetch には Node 標準 `fetch` を使う。1 回ダウンロードしたら
 *   `~/.cache/vibe-openscad/pdf/<sha-of-url>.pdf` に保存して、再 plan /
 *   再 run で何度もネットを叩かないようにする。
 * - PDF → PNG は `pdftoppm`(poppler-utils)に shell out する。OpenSCAD
 *   と同じく外部 CLI 依存だが、Linux/Mac の標準で入れやすい。
 */
import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  readdirSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { homedir, tmpdir } from "node:os";
import { join } from "node:path";

const CACHE_DIR = join(homedir(), ".cache", "vibe-openscad", "pdf");

/** URL の sha256(short) をファイル名キーに使う。中身が変わったかは
 *  キャッシュからは判定しないので、PDF を再取得したいときは手動で
 *  ~/.cache/vibe-openscad/pdf/ を消す。 */
function urlCachePath(url: string): string {
  const h = createHash("sha256").update(url).digest("hex").slice(0, 16);
  return join(CACHE_DIR, `${h}.pdf`);
}

export async function fetchPdfBytes(url: string): Promise<Buffer> {
  const cached = urlCachePath(url);
  if (existsSync(cached)) return readFileSync(cached);
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`PDF fetch failed: ${url} → ${res.status} ${res.statusText}`);
  }
  const buf = Buffer.from(await res.arrayBuffer());
  mkdirSync(CACHE_DIR, { recursive: true });
  writeFileSync(cached, buf);
  return buf;
}

/** PDF バイト列の sha256(content fingerprint 用)。 */
export function pdfContentHash(buf: Buffer): string {
  return createHash("sha256").update(buf).digest("hex");
}

/**
 * PDF の指定ページ群を PNG に切り出す。pdftoppm を一時ディレクトリで
 * 走らせて、出てきた PNG を Buffer 配列で返す。`pages` の順序通りに
 * 並んだ配列を返す(pdftoppm の `-f`/`-l` は連続範囲だけなので、ページ
 * ごとに 1 回呼ぶ)。
 *
 * dpi を上げるとディテールは増えるが PNG サイズが膨らむ。150 が
 * Anthropic / OpenAI / Gemini 共通で扱いやすい(画像トークンが暴れない)。
 */
export function extractPdfPagesAsPng(
  pdfBytes: Buffer,
  pages: number[],
  dpi = 150,
): Buffer[] {
  const tmp = mkdtempSync(join(tmpdir(), "vibe-pdf-"));
  try {
    const pdfPath = join(tmp, "in.pdf");
    writeFileSync(pdfPath, pdfBytes);
    const out: Buffer[] = [];
    for (const page of pages) {
      const prefix = join(tmp, `page-${page}`);
      try {
        execFileSync(
          "pdftoppm",
          [
            "-png",
            "-r",
            String(dpi),
            "-f",
            String(page),
            "-l",
            String(page),
            pdfPath,
            prefix,
          ],
          { stdio: ["ignore", "ignore", "pipe"] },
        );
      } catch (e) {
        throw new Error(
          `pdftoppm failed for page ${page}: ${(e as Error).message}`,
        );
      }
      // pdftoppm は出力ファイル名を `<prefix>-<N>.png` または `<prefix>.png`
      // の形にする(ページ数が 1 桁か複数桁かで挙動が変わる)。生成された
      // ファイルを総当たりで拾う。
      const generated = readdirSync(tmp).filter(
        (n) => n.startsWith(`page-${page}`) && n.endsWith(".png"),
      );
      if (generated.length === 0) {
        throw new Error(`pdftoppm produced no output for page ${page}`);
      }
      // 同じ page に対して複数 png が出ることは無いはず。1 枚目を採用。
      out.push(readFileSync(join(tmp, generated[0]!)));
    }
    return out;
  } finally {
    try {
      rmSync(tmp, { recursive: true, force: true });
    } catch {
      // best-effort
    }
  }
}
