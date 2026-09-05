import { describe, expect, it } from "vitest";
import { comparisonRows, comparisonSearch, readComparisonState, type ComparisonTask } from "./comparison.js";

const run = { href: "/run/a", image: "/a.png", status: "success", meta: "1s" };
const task: ComparisonTask = {
  id: "cube", title: "Cube", tier: 1, href: "/task/cube", prompt: "cube",
  models: [
    { id: "a", cells: [{ key: "baseline", family: "baseline", label: "単発", run }, { key: "iter:2", family: "iter", label: "iter 2", run }] },
    { id: "b", cells: [{ key: "baseline", family: "baseline", label: "単発", run }, { key: "iter:10", family: "iter", label: "iter 10", run }] },
  ],
};
const models = ["a", "b", "c"].map((id) => ({ id, label: id, provider: id }));

describe("comparison", () => {
  it("keeps selected model order and missing results across variants", () => {
    const rows = comparisonRows(task, ["b", "a", "c"]);
    expect(rows.map((r) => r.key)).toEqual(["baseline", "iter:2", "iter:10"]);
    expect(rows[1]!.runs).toEqual([null, run, null]);
    expect(rows[2]!.runs).toEqual([run, null, null]);
  });
  it("round trips selection order, slash-containing IDs, and collapsed families", () => {
    const state = { tasks: ["cube"], models: ["b", "a"], expanded: [] };
    expect(readComparisonState(comparisonSearch(state), [task], models)).toEqual(state);
    const slashModels = [{ id: "google/gemma", label: "gemma", provider: "google" }];
    expect(readComparisonState("?model=google%2Fgemma", [task], slashModels).models).toEqual(["google/gemma"]);
  });
  it("preserves an explicit empty selection and rejects unknown IDs", () => {
    expect(readComparisonState("?model=", [task], models).models).toEqual([]);
    expect(readComparisonState("?task=unknown&model=b&model=unknown&model=b", [task], models)).toMatchObject({ tasks: ["cube"], models: ["b"] });
  });
  it("keeps models selected when the task has no runs for them", () => {
    expect(readComparisonState("?model=c", [task], models).models).toEqual(["c"]);
    expect(comparisonRows(task, ["c"])).toEqual([]);
  });
  it("round trips multiple tasks in selection order and accepts old single-task URLs", () => {
    const tasks = [task, { ...task, id: "sphere" }];
    const state = { tasks: ["sphere", "cube"], models: ["b", "a"], expanded: ["iter"] };
    expect(readComparisonState(comparisonSearch(state), tasks, models)).toEqual(state);
    expect(readComparisonState("?task=cube&task=unknown&task=cube&task=sphere", tasks, models).tasks).toEqual(["cube", "sphere"]);
    expect(readComparisonState("?task=sphere", tasks, models).tasks).toEqual(["sphere"]);
    expect(readComparisonState("?task=", tasks, models).tasks).toEqual([]);
    expect(readComparisonState(comparisonSearch({ ...state, tasks: [] }), tasks, models).tasks).toEqual([]);
  });
});
