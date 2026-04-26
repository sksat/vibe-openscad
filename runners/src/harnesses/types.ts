import type { RenderResult } from "../render.js";
import type { Provider } from "../providers/types.js";
import type { RunStatus, Task } from "../schema.js";

export interface BareHarnessConfig {
  kind: "bare";
  provider: Provider;
  model: string;
  systemPrompt?: string;
  maxTokens?: number;
  modelOptions?: Record<string, unknown>;
}

export type HarnessConfig = BareHarnessConfig;

export interface HarnessContext {
  task: Task;
  config: HarnessConfig;
  render: (scad: string) => Promise<RenderResult>;
}

export interface HarnessLogBare {
  kind: "bare";
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
}
