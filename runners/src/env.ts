import { spawn } from "node:child_process";

export async function getOpenscadVersion(bin = "openscad"): Promise<string> {
  return getCommandVersion(bin, ["--version"]);
}

export function getCommandVersion(
  bin: string,
  args: string[],
): Promise<string> {
  return new Promise((resolve, reject) => {
    let stdout = "";
    let stderr = "";
    let proc: ReturnType<typeof spawn>;
    try {
      proc = spawn(bin, args, { stdio: ["ignore", "pipe", "pipe"] });
    } catch (e) {
      reject(e as Error);
      return;
    }
    proc.stdout?.on("data", (c: Buffer) => {
      stdout += c.toString("utf8");
    });
    proc.stderr?.on("data", (c: Buffer) => {
      stderr += c.toString("utf8");
    });
    proc.on("error", (err) => reject(err));
    proc.on("close", (code) => {
      if (code !== 0 && !stdout.trim() && !stderr.trim()) {
        reject(new Error(`${bin} ${args.join(" ")} exited ${code}`));
        return;
      }
      const out = (stdout.trim() || stderr.trim()).split(/\r?\n/)[0]?.trim();
      if (!out) {
        reject(new Error(`${bin} produced no version output`));
        return;
      }
      resolve(out);
    });
  });
}
