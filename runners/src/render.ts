import { spawn } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

export interface RenderOptions {
  openscadBin?: string;
  imgSize?: [number, number];
  /** Raw `--camera=` value, e.g. `"50,30,20,55,0,25,200"`. */
  camera?: string;
  /** Override the temp dir used for intermediates (mostly for tests). */
  workDir?: string;
}

export interface RenderResult {
  stl: Buffer;
  png: Buffer;
  stderr: string;
}

export type RenderStage = "stl" | "png";

export class RenderError extends Error {
  constructor(
    public readonly stage: RenderStage,
    public readonly exitCode: number | null,
    public readonly stderr: string,
  ) {
    super(`openscad ${stage} render failed (exit ${exitCode}): ${stderr}`);
    this.name = "RenderError";
  }
}

const DEFAULT_IMG_SIZE: [number, number] = [800, 600];
const DEFAULT_CAMERA = "0,0,0,55,0,25,140";

export async function renderScad(
  scad: string,
  opts: RenderOptions = {},
): Promise<RenderResult> {
  const bin = opts.openscadBin ?? "openscad";
  const baseTmp = opts.workDir ?? tmpdir();
  const dir = mkdtempSync(join(baseTmp, "render-"));
  const scadPath = join(dir, "input.scad");
  const stlPath = join(dir, "out.stl");
  const pngPath = join(dir, "out.png");

  let combinedStderr = "";

  try {
    writeFileSync(scadPath, scad);

    const stl = await runOpenscad(
      bin,
      ["-o", stlPath, scadPath],
      "stl",
    );
    combinedStderr += stl.stderr;

    const [w, h] = opts.imgSize ?? DEFAULT_IMG_SIZE;
    // Auto-fit the bounding box. Using --camera with a fixed distance
    // truncates large models. --autocenter + --viewall asks OpenSCAD to
    // frame the entire model with a sensible default angle.
    // If the caller forces a camera string, honor it (tests pass through).
    const cameraArgs = opts.camera
      ? [`--camera=${opts.camera}`]
      : ["--autocenter", "--viewall"];
    const png = await runOpenscad(
      bin,
      [
        "-o",
        pngPath,
        `--imgsize=${w},${h}`,
        ...cameraArgs,
        "--colorscheme=Tomorrow",
        scadPath,
      ],
      "png",
    );
    combinedStderr += png.stderr;

    return {
      stl: readFileSync(stlPath),
      png: readFileSync(pngPath),
      stderr: combinedStderr,
    };
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

interface RunResult {
  stderr: string;
}

function runOpenscad(
  bin: string,
  args: string[],
  stage: RenderStage,
): Promise<RunResult> {
  return new Promise((resolve, reject) => {
    const proc = spawn(bin, args, { stdio: ["ignore", "pipe", "pipe"] });
    let stderr = "";
    proc.stderr.on("data", (chunk: Buffer) => {
      stderr += chunk.toString("utf8");
    });
    proc.on("error", (err) => {
      reject(new RenderError(stage, null, `${err.message} :: ${stderr}`));
    });
    proc.on("close", (code) => {
      if (code === 0) {
        resolve({ stderr });
      } else {
        reject(new RenderError(stage, code, stderr));
      }
    });
  });
}
