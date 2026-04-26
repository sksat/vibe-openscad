import { chmodSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { getOpenscadVersion, getCommandVersion } from "./env.js";

let dir: string;

beforeEach(() => {
  dir = mkdtempSync(join(tmpdir(), "env-test-"));
});

afterEach(() => {
  rmSync(dir, { recursive: true, force: true });
});

function writeStub(name: string, body: string): string {
  const p = join(dir, name);
  writeFileSync(p, `#!/usr/bin/env bash\n${body}\n`);
  chmodSync(p, 0o755);
  return p;
}

describe("getOpenscadVersion", () => {
  it("returns the trimmed first line of `openscad --version`", async () => {
    const bin = writeStub("openscad-stub", `echo 'OpenSCAD version 2026.04.27'`);
    expect(await getOpenscadVersion(bin)).toBe("OpenSCAD version 2026.04.27");
  });

  it("captures version printed to stderr (older OpenSCAD)", async () => {
    const bin = writeStub(
      "openscad-old",
      `echo 'OpenSCAD version 2021.01' >&2`,
    );
    expect(await getOpenscadVersion(bin)).toBe("OpenSCAD version 2021.01");
  });

  it("throws when binary is missing", async () => {
    await expect(
      getOpenscadVersion(join(dir, "no-such-bin")),
    ).rejects.toThrow();
  });
});

describe("getCommandVersion", () => {
  it("runs the binary with the given args and trims output", async () => {
    const bin = writeStub("agent-stub", `echo '0.5.0-beta1'`);
    expect(await getCommandVersion(bin, ["--version"])).toBe("0.5.0-beta1");
  });
});
