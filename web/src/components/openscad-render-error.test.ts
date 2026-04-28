import { describe, expect, it } from "vitest";
import {
  buildErrorMessage,
  formatThrown,
  installConsoleCapture,
} from "./openscad-render-error.js";

describe("formatThrown", () => {
  it("returns the message of an Error", () => {
    expect(formatThrown(new Error("ERROR: bad token"))).toBe("ERROR: bad token");
  });

  it("formats a bare numeric throw as exit(N)", () => {
    // Emscripten が exit code そのものを throw するパターン。
    expect(formatThrown(1)).toBe("exit(1)");
    expect(formatThrown(255)).toBe("exit(255)");
  });

  it("uses .message on an ExitStatus-like object", () => {
    const exitStatus = {
      name: "ExitStatus",
      message: "Program terminated with exit(2).",
      status: 2,
    };
    expect(formatThrown(exitStatus)).toBe("Program terminated with exit(2).");
  });

  it("falls back to .status when an ExitStatus-like object lacks a usable message", () => {
    const exitStatus = { status: 3 };
    expect(formatThrown(exitStatus)).toBe("exit(3)");
  });

  it("returns a non-empty string verbatim", () => {
    expect(formatThrown("nope")).toBe("nope");
  });

  it("returns empty string for null/undefined/empty", () => {
    expect(formatThrown(null)).toBe("");
    expect(formatThrown(undefined)).toBe("");
    expect(formatThrown("")).toBe("");
  });
});

describe("buildErrorMessage", () => {
  it("prefers captured stderr when present", () => {
    // printErr 経由で OpenSCAD 本体のエラーが取れていればそれが最重要。
    const msg = buildErrorMessage(
      "ERROR: Parser error in file input.scad, line 5",
      1,
    );
    expect(msg).toContain("Parser error");
    expect(msg).toContain("line 5");
  });

  it("appends throw summary as auxiliary info when both are available", () => {
    const msg = buildErrorMessage(
      "ERROR: undefined operation",
      1,
    );
    expect(msg).toBe("ERROR: undefined operation\n(exit(1))");
  });

  it("falls back to throw summary when stderr is empty", () => {
    expect(buildErrorMessage("", 1)).toBe("exit(1)");
    expect(buildErrorMessage("", new Error("oops"))).toBe("oops");
  });

  it("never returns just a number — surfaces a non-empty placeholder if all sources are empty", () => {
    // ★ ユーザの「エラーがよくわからない数字なんだけど」が再発しないための
    // ガード。stderr 空 + throw 空(または "" / 0)の組み合わせでも、
    // UI には「何が起きたか」を示す文字列が必ず出る。
    expect(buildErrorMessage("", null)).toBe("OpenSCAD failed (no error message)");
    expect(buildErrorMessage("", "")).toBe("OpenSCAD failed (no error message)");
    expect(buildErrorMessage("   \n  ", undefined)).toBe(
      "OpenSCAD failed (no error message)",
    );
  });

  it("trims whitespace-only stderr before deciding it's empty", () => {
    expect(buildErrorMessage("   \n   ", new Error("real"))).toBe("real");
  });
});

describe("installConsoleCapture", () => {
  // openscad-wasm の Emscripten ラッパーは
  //   var err = console.error.bind(console)
  // と書かれており、Module.printErr では捕まらない。やむなく console を
  // 一時的に差し替えて、bind 後の参照経由で stderrBuf に流れ込ませる。
  // installConsoleCapture はそのオン/オフと buffer 接続を管理する。

  it("captures synchronous console.log/error calls into the provided buffer", () => {
    const buf: string[] = [];
    const origLog = console.log;
    const origErr = console.error;
    const handle = installConsoleCapture(buf);
    try {
      console.error("ERROR: parser failed");
      console.log("WARNING: unused");
      expect(buf).toEqual(["ERROR: parser failed", "WARNING: unused"]);
    } finally {
      handle.uninstall();
    }
    expect(console.log).toBe(origLog);
    expect(console.error).toBe(origErr);
  });

  it("preserves bind() snapshots taken while the override was active", () => {
    // ★ openscad-wasm が `console.error.bind(console)` を内部で呼ぶ。
    // install → bind → uninstall の順でも、bind 済み参照は capture を
    // 指し続ける(これが capture が動作する根拠)。
    const buf: string[] = [];
    const handle = installConsoleCapture(buf);
    const boundError = console.error.bind(console);
    handle.uninstall();
    boundError("late error");
    expect(buf).toEqual(["late error"]);
  });

  it("joins multiple arguments with spaces", () => {
    const buf: string[] = [];
    const handle = installConsoleCapture(buf);
    try {
      console.error("ERROR:", "line", 5);
    } finally {
      handle.uninstall();
    }
    expect(buf).toEqual(["ERROR: line 5"]);
  });

  it("uninstall is idempotent and never restores stale handlers", () => {
    const buf: string[] = [];
    const origErr = console.error;
    const handle = installConsoleCapture(buf);
    handle.uninstall();
    handle.uninstall();
    expect(console.error).toBe(origErr);
  });
});
