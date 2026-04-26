import { describe, expect, it } from "vitest";
import { failuresSection, header, itemLine, summary } from "./format.js";

const NO_COLOR = { color: false } as const;

describe("header", () => {
  it("prints 'running N <noun>'", () => {
    expect(header(3, "candidates")).toBe("running 3 candidates");
    expect(header(1, "candidate")).toBe("running 1 candidate");
  });
});

describe("itemLine", () => {
  it("formats verb name ... status without color", () => {
    expect(
      itemLine({ verb: "plan", name: "claude-bare::tier-1-cube", status: "missing" }, NO_COLOR),
    ).toBe("plan claude-bare::tier-1-cube ... missing");
  });

  it("appends a hint in parentheses when given", () => {
    expect(
      itemLine(
        {
          verb: "bench",
          name: "claude-bare::tier-1-mug",
          status: "FAILED",
          hint: "render_error",
        },
        NO_COLOR,
      ),
    ).toBe("bench claude-bare::tier-1-mug ... FAILED (render_error)");
  });
});

describe("summary", () => {
  it("formats the trailing summary with finished-in", () => {
    expect(
      summary({
        kind: "bench",
        ok: true,
        counts: { passed: 2, failed: 0, skipped: 1 },
        durationMs: 12345,
      }),
    ).toBe(
      "bench result: ok. 2 passed; 0 failed; 1 skipped; finished in 12.35s",
    );
  });

  it("marks FAILED when ok=false", () => {
    expect(
      summary({
        kind: "bench",
        ok: false,
        counts: { passed: 1, failed: 2, skipped: 0 },
        durationMs: 1000,
      }),
    ).toBe(
      "bench result: FAILED. 1 passed; 2 failed; 0 skipped; finished in 1.00s",
    );
  });

  it("plan summary uses missing/stale/up-to-date counts", () => {
    expect(
      summary({
        kind: "plan",
        counts: { missing: 2, stale: 1, upToDate: 4 },
      }),
    ).toBe("plan result: 2 missing; 1 stale; 4 up-to-date");
  });
});

describe("failuresSection", () => {
  it("returns empty string when no failures", () => {
    expect(failuresSection([])).toBe("");
  });

  it("renders cargo-test-style failures block", () => {
    const out = failuresSection([
      { name: "a::b", detail: "boom\nstack..." },
      { name: "c::d", detail: "kaboom" },
    ]);
    expect(out).toContain("failures:");
    expect(out).toContain("---- a::b ----");
    expect(out).toContain("boom");
    expect(out).toContain("---- c::d ----");
    expect(out).toContain("kaboom");
    expect(out.match(/failures:/g)?.length).toBe(2); // header + final list header
    expect(out).toContain("    a::b");
    expect(out).toContain("    c::d");
  });
});
