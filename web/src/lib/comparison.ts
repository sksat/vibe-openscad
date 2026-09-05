export interface ComparisonRun {
  href: string;
  image?: string | undefined;
  status: string;
  meta: string;
}
export interface ComparisonCell {
  key: string;
  family: string;
  label: string;
  run: ComparisonRun;
}
export interface ComparisonModel {
  id: string;
  label: string;
  provider: string;
}
export interface ComparisonTask {
  id: string;
  title: string;
  tier: number;
  href: string;
  prompt: string;
  models: { id: string; cells: ComparisonCell[] }[];
}
export interface ComparisonState {
  tasks: string[];
  models: string[];
  expanded: string[];
}

export function readComparisonState(search: string, tasks: ComparisonTask[], models: ComparisonModel[]): ComparisonState {
  const params = new URLSearchParams(search);
  const knownModels = new Set(models.map((m) => m.id));
  const chosen = [...new Set(params.getAll("model"))].filter((id) => knownModels.has(id));
  const knownTasks = new Set(tasks.map((task) => task.id));
  const chosenTasks = [...new Set(params.getAll("task"))].filter((id) => knownTasks.has(id));
  const defaults: string[] = [];
  const providers = new Set<string>();
  for (const model of models) {
    if (!providers.has(model.provider) && defaults.length < 3) {
      defaults.push(model.id);
      providers.add(model.provider);
    }
  }
  for (const model of models) {
    if (defaults.length < 3 && !defaults.includes(model.id)) defaults.push(model.id);
  }
  return {
    tasks: chosenTasks.length ? chosenTasks : params.getAll("task").includes("") ? [] : tasks.slice(0, 1).map((task) => task.id),
    models: params.has("model") ? chosen : defaults,
    expanded: params.has("expanded") ? params.getAll("expanded").filter(Boolean) : ["iter"],
  };
}

export function comparisonSearch(state: ComparisonState): string {
  const params = new URLSearchParams();
  for (const id of state.tasks.length ? state.tasks : [""]) params.append("task", id);
  for (const id of state.models.length ? state.models : [""]) params.append("model", id);
  for (const family of state.expanded.length ? state.expanded : [""]) params.append("expanded", family);
  return `?${params}`;
}

/** Union conditions while preserving the model columns, including missing runs. */
export function comparisonRows(task: ComparisonTask, selected: string[]) {
  const conditions = new Map<string, Pick<ComparisonCell, "key" | "family" | "label">>();
  for (const id of selected) {
    for (const cell of task.models.find((m) => m.id === id)?.cells ?? []) {
      conditions.set(cell.key, { key: cell.key, family: cell.family, label: cell.label });
    }
  }
  const order = ["baseline", "iter", "effort", "thinking"];
  const efforts = ["minimal", "low", "medium", "high", "max", "xhigh"];
  return [...conditions.values()].sort((a, b) => {
    const rank = (family: string) => order.includes(family) ? order.indexOf(family) : 99;
    const familyOrder = rank(a.family) - rank(b.family);
    if (familyOrder) return familyOrder;
    if (a.family === "effort" && b.family === "effort") {
      const effortRank = (key: string) => {
        const index = efforts.indexOf(key.replace(/^bare-|^effort:/, ""));
        return index < 0 ? 99 : index;
      };
      const effortOrder = effortRank(a.key) - effortRank(b.key);
      if (effortOrder) return effortOrder;
    }
    return a.key.localeCompare(b.key, undefined, { numeric: true });
  }).map((condition) => ({
    ...condition,
    runs: selected.map((id) => task.models.find((m) => m.id === id)?.cells.find((c) => c.key === condition.key)?.run ?? null),
  }));
}
