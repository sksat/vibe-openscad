# CLAUDE.md — AI 協働者向け作業ガイド

このファイルは Claude Code 等の AI エージェントがこのリポジトリで作業するときに最初に読むためのもの。
**プロジェクト固有の設計判断(なぜそうなっているか)は `DESIGN.md` 側にある** — 最初に読むこと。
ここに書くのはどう作業を進めるかという **メタな方法論** のみ。

## 守るべき方法論

### 1. TDD で進める

新機能・バグ修正は **テスト先行**。Red → Green → Refactor。

- `pnpm test` で全パッケージの Vitest が走る
- 関数・モジュールを書くときは先に `*.test.ts` を作って失敗を確認、それから実装
- 外部 API / OpenSCAD CLI / MCP クライアントなどはテストでモックする(再現性とコスト 0 のため)

### 2. モデル追加はデータで完結させる

新しい LLM をベンチに載せるときは **`models.yml` に 1 エントリ + `bench-config.yml` に
matrix 行** を足すだけにする。価格・vision 可否・既定 effort をコードへ書き足さない。

そのモデル用のテストも **新しく書かない** — 網羅テスト
(`runners/src/models.test.ts` / `web/src/lib/model-coverage.test.ts`)が
bench-config を走査して登録漏れを検出する。落ちたらテストを直すのではなく
カタログを埋める。詳細は DESIGN.md「モデルカタログ」節。

例外は「そのモデルで API の作法自体が変わる」場合(新しい thinking パラメータ等)。
これは provider 実装の変更なので通常どおり TDD で進める。

#### 追加前に dated snapshot の有無を調べる

alias(`claude-opus-5`、`gemini-3.5-flash`)は provider の都合で別のスナップ
ショットを指すように差し替わりうるが、fingerprint は alias 文字列しか見ないので
差し替えを検出できない。**dated snapshot や具体バージョン ID が公開されている
なら、そちらを bench-config に書く**(理由は DESIGN.md「モデル指定の方針」)。

追加作業を始める前に、その provider で何が公開されているか確認する:

| provider | 調べ方 | 備考 |
|---|---|---|
| OpenAI | `pnpm --filter runners run list-openai-models` | dated id がそのまま並ぶ(`gpt-5.4-2026-03-05`) |
| Anthropic | Models API の `client.models.list()` | dated id が並ぶ(`claude-haiku-4-5-20251001`)。**応答の `model` は alias のまま返る**ので、実行結果からは分からない |
| Google | Models API の `models.get()` が返す `version` | id は alias でも `version` が実体を指す(`gemini-3.1-pro-preview` → `3.1-pro-preview-01-2026`) |

dated が無く alias しか手段が無いモデルもある(Anthropic の現行世代など)。その
場合は alias のままでよいが、**カタログの `snapshot` に provider が名乗る値を
書いておく**と、後から差し替えに気付ける。

### 3. 設計判断は DESIGN.md に書く

プロジェクト固有の意思決定は **DESIGN.md に書く**。コード中のコメント、個人 memory、PR 説明だけに残さない。
このファイル(CLAUDE.md)に設計事項を書かないこと — ここはあくまで方法論。

設計を変える場合の順序:

1. DESIGN.md を更新(なぜ変えるかも書く)
2. 必要なテストを書く(red)
3. 実装(green)

### 4. 既存設計の不変条件を読んでから変更する

DESIGN.md には「signature ベースの差分実行」「`api_error` は results に書かない」「dated snapshot を優先」など **不変条件として依存している判断** が書いてある。
これらを変えるときは影響範囲を意識する(過去 run との比較が壊れないか、キャッシュが効かなくなる範囲はどこか、など)。
不変条件を変える PR では DESIGN.md の該当節も同 PR で更新する。

## よく使うコマンド

| 用途 | コマンド |
|---|---|
| 全テスト | `pnpm test` |
| 型チェック | `pnpm typecheck` |
| ベンチ計画(API は叩かない) | `pnpm bench plan` |
| ベンチ実行(差分のみ) | `pnpm bench run` |
| ベンチ実行(強制全件) | `pnpm bench run --force` |
| 単一フィルタ実行 | `pnpm bench run --filter <id>`(`vendor:task` で AND マッチ) |
| 旧 run を作り直す前に削除 | `pnpm bench run --prune` |
| 既存 SCAD だけ再レンダリング | `pnpm bench rerender` |
| OpenAI 実利用可能モデル一覧 | `pnpm --filter runners run list-openai-models` |
| サイト dev | `pnpm --filter web dev` |
| サイトビルド | `pnpm --filter web build` |

## 環境変数

`pnpm bench` 実行時にリポジトリルートの `.env` を自動で読む(Node 22+ の `process.loadEnvFile`)。`.env` は gitignore 済み、テンプレートは `.env.example`。

`.env` の中身は **Claude Code には読ませない**。`.claude/settings.json` で Read tool と `cat` / `head` / `tail` / `grep` 等の Bash コマンドを deny している。

- `ANTHROPIC_API_KEY` — Anthropic provider 用
- `OPENAI_API_KEY` — OpenAI provider 用
- `GEMINI_API_KEY` / `GOOGLE_API_KEY` — Gemini provider 用
- `OPENAI_SELF_HOSTED_BASE_URL`(任意) — セルフホスト OpenAI 互換 endpoint(LM Studio / Ollama / llama.cpp / vLLM 等)。`/v1` 込みで指定(例 `http://asuha:1234/v1`)。フォールバックで旧 `OLLAMA_HOST`(/v1 を自動補完)も読む
