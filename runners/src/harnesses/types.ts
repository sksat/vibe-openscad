import type { RenderResult } from "../render.js";
import type { Provider } from "../providers/types.js";
import type { IterationStrategy, RunStatus, Task } from "../schema.js";

export interface BareHarnessConfig {
  kind: "bare";
  provider: Provider;
  model: string;
  systemPrompt?: string;
  maxTokens?: number;
  modelOptions?: Record<string, unknown>;
  /** Iteration strategy. Omitted = single-shot. */
  iteration?: IterationStrategy;
}

export type HarnessConfig = BareHarnessConfig;

/** Predecessor run's artifacts, fed into an iteration step. */
export interface ParentRunContext {
  runId: string;
  scad: string;
  png?: Buffer;
  errorMessage?: string;
}

export interface HarnessContext {
  task: Task;
  config: HarnessConfig;
  render: (scad: string) => Promise<RenderResult>;
  /** Set when this run is an iteration step (config.iteration is also set). */
  parent?: ParentRunContext;
}

export interface HarnessLogBare {
  kind: "bare";
  iteration?: IterationStrategy;
}

export type HarnessLog = HarnessLogBare;

export interface HarnessResult {
  status: RunStatus;
  scad?: string;
  stl?: Buffer;
  png?: Buffer;
  durationMs: number;
  tokens?: { input: number; output: number };
  modelId?: string;
  harnessLog: HarnessLog;
  errorMessage?: string;
  /** Raw model response text, before SCAD extraction (prose, fences, etc). */
  rawResponse?: string;
}
