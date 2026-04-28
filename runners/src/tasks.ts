import { createHash } from "node:crypto";
import { readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { parse as parseYaml } from "yaml";
import { canonicalJson } from "./canonical.js";
import { fetchPdfBytes, pdfContentHash } from "./pdf.js";
import { type Task, TaskSchema } from "./schema.js";

export async function loadTaskFile(path: string): Promise<Task> {
  const raw = readFileSync(path, "utf8");
  let parsed: unknown;
  try {
    parsed = parseYaml(raw);
  } catch (e) {
    throw new Error(`failed to parse YAML at ${path}: ${(e as Error).message}`);
  }
  const result = TaskSchema.safeParse(parsed);
  if (!result.success) {
    throw new Error(
      `invalid task YAML at ${path}: ${result.error.issues
        .map((i) => `${i.path.join(".")}: ${i.message}`)
        .join("; ")}`,
    );
  }
  const task = result.data;
  if (task.prompt_images && task.prompt_images.length > 0) {
    // YAML にあるパスは task ファイルからの相対(`./img.png` 等)。
    // ロード時に bytes を読み、sha256 を計算して fingerprint 用の
    // `prompt_image_hashes` を埋める。バイト列は harness が provider
    // に渡す用に `prompt_image_data` として持ち回す(canonical JSON
    // 経由のときだけ除外する)。
    const baseDir = dirname(path);
    const data: Buffer[] = [];
    const hashes: string[] = [];
    for (const rel of task.prompt_images) {
      const abs = resolve(baseDir, rel);
      let buf: Buffer;
      try {
        buf = readFileSync(abs);
      } catch (e) {
        throw new Error(
          `task ${task.id}: prompt_images entry not found: ${rel} (resolved to ${abs}): ${
            (e as Error).message
          }`,
        );
      }
      data.push(buf);
      hashes.push(createHash("sha256").update(buf).digest("hex"));
    }
    task.prompt_image_data = data;
    task.prompt_image_hashes = hashes;
  }
  if (task.pdf_source) {
    // PDF は大きめで毎回ダウンロードしたくないので fetchPdfBytes 側に
    // disk cache がある。content sha256 を fingerprint に乗せて、PDF が
    // 差し替わったら taskHash 経由で stale → 再 run トリガになるように
    // する。ページ画像自体は実行時に pdftoppm で展開する(harness 側)
    // ので、ロード時はバイト列を取って hash するだけ。
    try {
      const bytes = await fetchPdfBytes(task.pdf_source.url);
      task.pdf_source_hash = pdfContentHash(bytes);
    } catch (e) {
      throw new Error(
        `task ${task.id}: failed to fetch pdf_source ${task.pdf_source.url}: ${
          (e as Error).message
        }`,
      );
    }
  }
  return task;
}

export async function loadAllTasks(rootDir: string): Promise<Task[]> {
  const tasks: Task[] = [];
  const seen = new Map<string, string>();
  for (const file of walkYamlFiles(rootDir)) {
    const task = await loadTaskFile(file);
    const prev = seen.get(task.id);
    if (prev) {
      throw new Error(
        `duplicate task id "${task.id}" found in ${prev} and ${file}`,
      );
    }
    seen.set(task.id, file);
    tasks.push(task);
  }
  return tasks;
}

function* walkYamlFiles(dir: string): Generator<string> {
  let entries: string[];
  try {
    entries = readdirSync(dir);
  } catch {
    return;
  }
  for (const name of entries.sort()) {
    const full = join(dir, name);
    const st = statSync(full);
    if (st.isDirectory()) {
      yield* walkYamlFiles(full);
    } else if (st.isFile() && (name.endsWith(".yml") || name.endsWith(".yaml"))) {
      yield full;
    }
  }
}

export function computeTaskHash(task: Task): string {
  // fingerprint(再実行のトリガ)は「task の意味的内容」だけ反映したい:
  //  - `slug` は URL 用の人間可読名なので除外(rename しても再走しない)
  //  - `prompt_images` は path 文字列で、環境/レイアウト次第で揺れる
  //    ので除外。代わりに `prompt_image_hashes`(content sha256)を
  //    含めて、画像ファイル中身の差し替えだけが再走トリガになるように
  //  - `prompt_image_data`(Buffer)は canonicalJson に流すと壊れるので除外。
  //    どうせ `prompt_image_hashes` が同等の情報を担っている。
  // 同様に pdf_source(URL/pages 構造)も中身ベースで判定したいので
  // URL は除外。pages 数値と pdf_source_hash(中身)が hash に効く。
  const {
    slug: _slug,
    prompt_images: _pi,
    prompt_image_data: _pid,
    pdf_source: _ps,
    ...rest
  } = task;
  // pdf_source は除外したが pages は再現性に関わるので別フィールドとして
  // 残したい。`pdf_source_hash` と並べて hashable な形にして詰め直す。
  const pdfPagesField = task.pdf_source
    ? { pdf_source_pages: task.pdf_source.pages }
    : {};
  return createHash("sha256")
    .update(canonicalJson({ ...rest, ...pdfPagesField }))
    .digest("hex");
}
