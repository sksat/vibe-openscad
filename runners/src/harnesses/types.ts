import type { RenderResult } from "../render.js";
import type { ModelMetadata, Provider } from "../providers/types.js";
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

/**
 * PDF の指定ページを画像として provider に渡すハーネス。bare と同じく
 * 1 回 LLM を叩いて SCAD を抜くだけだが、前段に「task.pdf_source の
 * URL を取ってきて pdftoppm で切り出す」 preprocessing が入る。
 */
export interface PdfPageHarnessConfig {
  kind: "pdf-page";
  provider: Provider;
  model: string;
  systemPrompt?: string;
  maxTokens?: number;
  modelOptions?: Record<string, unknown>;
  iteration?: IterationStrategy;
}

export type HarnessConfig = BareHarnessConfig | PdfPageHarnessConfig;

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
  /** Self-hosted LLM のモデル個体メタデータ(publisher / quant 等)。
   *  クラウド provider では undefined。 */
  modelMetadata?: ModelMetadata;
}

export interface HarnessLogPdfPage {
  kind: "pdf-page";
  iteration?: IterationStrategy;
  pdfUrl?: string;
  pages?: number[];
  modelMetadata?: ModelMetadata;
}

export type HarnessLog = HarnessLogBare | HarnessLogPdfPage;

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
