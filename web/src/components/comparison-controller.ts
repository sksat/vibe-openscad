import { comparisonRows, comparisonSearch, readComparisonState, type ComparisonModel, type ComparisonTask } from "../lib/comparison.js";

export function initComparison(root: HTMLElement) {
  const doc = root.ownerDocument;
  const win = doc.defaultView!;
  const data = JSON.parse(root.querySelector("[data-comparison-data]")!.textContent!) as { tasks: ComparisonTask[]; models: ComparisonModel[] };
  const { tasks, models } = data;
  let state = readComparisonState(win.location.search, tasks, models);
  const head = root.querySelector("[data-board-head]")!;
  const body = root.querySelector("[data-board-body]")!;
  const status = root.querySelector<HTMLElement>("[data-comparison-status]")!;
  const empty = root.querySelector<HTMLElement>("[data-comparison-empty]")!;
  const board = root.querySelector<HTMLElement>("[data-board]")!;
  // Reuse the server-rendered VendorIcon so icon paths and vendor resolution stay shared.
  const icons = new Map<string, SVGElement>();
  for (const option of root.querySelectorAll<HTMLElement>("[data-model-option]")) {
    const id = option.querySelector<HTMLInputElement>("[data-model-choice]")?.value;
    const icon = option.querySelector<SVGElement>(".vendor-icon");
    if (id && icon) icons.set(id, icon);
  }
  function addModelIcon(el: HTMLElement, id: string) {
    el.classList.add("model-identity");
    const icon = icons.get(id);
    if (icon) el.prepend(icon.cloneNode(true));
  }
  const familyNames: Record<string, string> = { iter: "iter · 修正の変化", effort: "effort · 推論の強度", thinking: "thinking · 思考設定", other: "その他の実行条件" };
  function element<K extends keyof HTMLElementTagNameMap>(tag: K, text = "", className = ""): HTMLElementTagNameMap[K] {
    const el = doc.createElement(tag);
    el.textContent = text;
    el.className = className;
    return el;
  }
  function render() {
    const selectedTasks = state.tasks.map((id) => tasks.find((task) => task.id === id)!);
    const index = tasks.findIndex((t) => t.id === state.tasks[0]);
    const single = selectedTasks.length === 1;
    root.querySelector<HTMLButtonElement>("[data-task-prev]")!.disabled = !single || index <= 0;
    root.querySelector<HTMLButtonElement>("[data-task-next]")!.disabled = !single || index < 0 || index >= tasks.length - 1;
    root.querySelector<HTMLElement>(".task-navigation")!.hidden = !single;
    root.querySelector("[data-task-selection]")!.textContent = single ? selectedTasks[0]!.title : `${selectedTasks.length} 選択中`;
    for (const checkbox of root.querySelectorAll<HTMLInputElement>("[data-task-choice]")) checkbox.checked = state.tasks.includes(checkbox.value);
    root.querySelector("[data-selection-count]")!.textContent = `${state.models.length} モデル`;
    for (const checkbox of root.querySelectorAll<HTMLInputElement>("[data-model-choice]")) checkbox.checked = state.models.includes(checkbox.value);
    const chips = root.querySelector("[data-selected-models]")!;
    chips.replaceChildren();
    for (const id of state.models) {
      const model = models.find((m) => m.id === id)!;
      const button = element("button", `${model.label} ×`);
      addModelIcon(button, id);
      button.type = "button";
      button.setAttribute("aria-label", `${model.label} を比較から外す`);
      button.addEventListener("click", () => { state.models = state.models.filter((m) => m !== id); update(); root.querySelector<HTMLInputElement>("[data-model-search]")?.focus(); });
      chips.append(button);
    }
    head.replaceChildren();
    body.replaceChildren();
    empty.hidden = selectedTasks.length > 0 && state.models.length > 0;
    board.parentElement!.hidden = !empty.hidden;
    if (!empty.hidden) {
      empty.textContent = !selectedTasks.length ? "比較する task を選択してください。" : "比較したいモデルを上の一覧から選択してください。";
      status.textContent = "";
      return;
    }
    board.style.setProperty("--model-count", String(state.models.length));
    root.querySelector("[data-board-caption]")!.textContent = `${selectedTasks.map((task) => task.title).join(" / ")}：モデルを列、task と実行条件を行に表示`;
    const header = element("tr");
    const corner = element("th", "実行条件");
    corner.scope = "col";
    header.append(corner);
    for (const id of state.models) {
      const model = models.find((m) => m.id === id)!;
      const th = element("th");
      th.scope = "col";
      const a = element("a", model.label);
      addModelIcon(a, id);
      a.href = `/models/${id}`;
      th.append(a, element("small", id));
      header.append(th);
    }
    head.append(header);
    for (const task of selectedTasks) {
      const taskRow = element("tr", "", "task-heading");
      taskRow.dataset["compareTask"] = task.id;
      const taskCell = element("th");
      taskCell.colSpan = state.models.length + 1;
      const taskInfo = element("div", "", "task-info");
      const taskLink = element("a", `Tier ${task.tier} · ${task.title}`);
      taskLink.href = task.href;
      const prompt = element("details", "", "task-prompt");
      prompt.append(element("summary", "prompt"), element("p", task.prompt));
      taskInfo.append(taskLink, prompt);
      taskCell.append(taskInfo);
      taskRow.append(taskCell);
      body.append(taskRow);
      const rows = comparisonRows(task, state.models);
      // A selected model with no run must still keep its column, even for an entirely empty task.
      if (!rows.length) rows.push({ key: "baseline", family: "baseline", label: "単発 · 既定設定", runs: state.models.map(() => null) });
      const families = [...new Set(rows.map((row) => row.family))];
      for (const family of families) {
        const familyRows = rows.filter((r) => r.family === family);
        if (family !== "baseline") {
          const tr = element("tr", "", "family-heading");
          const th = element("th");
          th.colSpan = state.models.length + 1;
          const open = state.expanded.includes(family);
          const toggle = element("button", `${open ? "▾" : "▸"} ${familyNames[family] ?? family} (${familyRows.length} 条件)`);
          toggle.type = "button";
          toggle.dataset["familyToggle"] = family;
          toggle.dataset["taskId"] = task.id;
          toggle.title = "すべての tasks でこの条件を展開・折りたたみ";
          toggle.setAttribute("aria-expanded", String(open));
          toggle.addEventListener("click", () => {
            state.expanded = open ? state.expanded.filter((f) => f !== family) : [...state.expanded, family];
            update();
            [...root.querySelectorAll<HTMLButtonElement>("[data-family-toggle]")].find((b) => b.dataset["familyToggle"] === family && b.dataset["taskId"] === task.id)?.focus({ preventScroll: true });
          });
          th.append(toggle); tr.append(th); body.append(tr);
          if (!open) continue;
        }
        for (const row of familyRows) {
          const tr = element("tr");
          tr.dataset["condition"] = row.key;
          tr.dataset["taskId"] = task.id;
          const label = element("th", row.label);
          label.scope = "row";
          tr.append(label);
          row.runs.forEach((run, index) => {
            const td = element("td");
            if (!run) td.append(element("div", "この条件の結果なし", "no-render"));
            else {
              if (run.image) {
                const a = element("a", "", "render-link");
                a.href = run.href;
                a.setAttribute("aria-label", `${state.models[index]} · ${row.label} の実行詳細と 3D 表示`);
                const img = element("img");
                img.src = run.image;
                img.alt = `${state.models[index]} · ${task.title} · ${row.label}`;
                img.loading = "lazy";
                a.append(img); td.append(a);
              } else {
                const a = element("a", "レンダリング画像なし · 詳細 →", "no-render");
                a.href = run.href;
                td.append(a);
              }
              const meta = element("div", "", "run-meta");
              const badge = element("span", run.status, "run-status");
              badge.dataset["status"] = run.status;
              meta.append(badge, element("span", run.meta));
              td.append(meta);
            }
            tr.append(td);
          });
          body.append(tr);
        }
      }
    }
    status.textContent = `${selectedTasks.length} tasks · ${state.models.length} models`;
  }
  function update() {
    win.history.pushState(null, "", comparisonSearch(state));
    render();
  }
  for (const checkbox of root.querySelectorAll<HTMLInputElement>("[data-task-choice]")) {
    checkbox.addEventListener("change", () => {
      state.tasks = checkbox.checked ? [...state.tasks, checkbox.value] : state.tasks.filter((id) => id !== checkbox.value);
      update();
    });
  }
  root.querySelector("[data-all-tasks]")!.addEventListener("click", () => { state.tasks = tasks.map((task) => task.id); update(); });
  root.querySelector("[data-clear-tasks]")!.addEventListener("click", () => { state.tasks = []; update(); });
  for (const [selector, delta] of [["[data-task-prev]", -1], ["[data-task-next]", 1]] as const) {
    root.querySelector(selector)!.addEventListener("click", () => {
      const next = tasks[tasks.findIndex((t) => t.id === state.tasks[0]) + delta];
      if (next && state.tasks.length === 1) { state.tasks = [next.id]; update(); }
    });
  }
  for (const checkbox of root.querySelectorAll<HTMLInputElement>("[data-model-choice]")) {
    checkbox.addEventListener("change", () => {
      state.models = checkbox.checked ? [...state.models, checkbox.value] : state.models.filter((id) => id !== checkbox.value);
      update();
    });
  }
  root.querySelector("[data-clear-models]")!.addEventListener("click", () => { state.models = []; update(); });
  root.querySelector<HTMLInputElement>("[data-model-search]")!.addEventListener("input", (event) => {
    const query = (event.target as HTMLInputElement).value.trim().toLowerCase();
    const options = [...root.querySelectorAll<HTMLElement>("[data-model-option]")];
    for (const option of options) option.hidden = !option.dataset["search"]!.includes(query);
    root.querySelector<HTMLElement>("[data-search-empty]")!.hidden = options.some((o) => !o.hidden);
  });
  root.querySelector("[data-share]")!.addEventListener("click", async () => {
    const url = new URL(comparisonSearch(state), win.location.href).href;
    try { await win.navigator.clipboard.writeText(url); status.textContent = "比較 URL をコピーしました。"; }
    catch { win.history.replaceState(null, "", url); status.textContent = "アドレスバーの URL をコピーして共有できます。"; }
  });
  win.addEventListener("popstate", () => { state = readComparisonState(win.location.search, tasks, models); render(); });
  render();
}
