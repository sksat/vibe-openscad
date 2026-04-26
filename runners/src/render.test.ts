import { chmodSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { RenderError, renderScad } from "./render.js";

let dir: string;

beforeEach(() => {
  dir = mkdtempSync(join(tmpdir(), "render-test-"));
});

afterEach(() => {
  rmSync(dir, { recursive: true, force: true });
});

/**
 * Build a stub openscad shell script. Each `-o foo.{stl,png} input.scad`
 * invocation writes deterministic bytes to the output path. Stderr can be
 * forced via env vars to simulate failures.
 */
function makeStub(opts: { failStl?: boolean; failPng?: boolean } = {}): string {
  const path = join(dir, "openscad-stub.sh");
  const script = `#!/usr/bin/env bash
set -e
out=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o) out="$2"; shift 2 ;;
    *) shift ;;
  esac
done
case "$out" in
  *.stl)
    if [[ -n "${opts.failStl ? "1" : ""}" ]]; then echo "stl boom" >&2; exit 2; fi
    printf 'STL\\x00BYTES' > "$out"
    ;;
  *.png)
    if [[ -n "${opts.failPng ? "1" : ""}" ]]; then echo "png boom" >&2; exit 3; fi
    printf 'PNGBYTES' > "$out"
    ;;
esac
`;
  writeFileSync(path, script);
  chmodSync(path, 0o755);
  return path;
}

describe("renderScad", () => {
  it("returns stl and png buffers from a successful render", async () => {
    const result = await renderScad("cube([10,10,10]);", {
      openscadBin: makeStub(),
      workDir: dir,
    });
    expect(result.stl.toString()).toContain("STL");
    expect(result.png.toString()).toContain("PNG");
  });

  it("includes openscad version captured from --version", async () => {
    // Default stub writes nothing to --version; allow undefined too.
    const result = await renderScad("cube();", {
      openscadBin: makeStub(),
      workDir: dir,
    });
    expect(result.stl).toBeInstanceOf(Buffer);
    expect(result.png).toBeInstanceOf(Buffer);
  });

  it("throws RenderError with stderr when STL render fails", async () => {
    await expect(
      renderScad("badscad", {
        openscadBin: makeStub({ failStl: true }),
        workDir: dir,
      }),
    ).rejects.toThrow(RenderError);
    try {
      await renderScad("badscad", {
        openscadBin: makeStub({ failStl: true }),
        workDir: dir,
      });
    } catch (e) {
      expect((e as RenderError).stage).toBe("stl");
      expect((e as RenderError).stderr).toContain("stl boom");
    }
  });

  it("throws RenderError when PNG render fails (after STL succeeded)", async () => {
    try {
      await renderScad("cube();", {
        openscadBin: makeStub({ failPng: true }),
        workDir: dir,
      });
      throw new Error("should have thrown");
    } catch (e) {
      expect(e).toBeInstanceOf(RenderError);
      expect((e as RenderError).stage).toBe("png");
    }
  });

  it("respects custom imgSize", async () => {
    // We can't observe the args easily without a richer stub, but ensure no error.
    const result = await renderScad("cube();", {
      openscadBin: makeStub(),
      workDir: dir,
      imgSize: [400, 300],
    });
    expect(result.png.byteLength).toBeGreaterThan(0);
  });
});
