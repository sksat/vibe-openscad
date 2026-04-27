# DESIGN

vibe-openscad のアーキテクチャと設計判断を記す。実装の正解ではなく「なぜそう作るか」を残す場所。実装手順そのものは `~/.claude/plans/` のプランや CLAUDE.md を参照。

## 目的

LLM の 3 次元空間認識力を比較・可視化する公開ベンチマーク。複数の AI モデルおよび AI ハーネス(Claude Code 等)に同一の課題で OpenSCAD コードを書かせ、結果を Web サイトで横並びに表示する。

## 全体方針

- **実行と表示を分離**: ベンチマーク実行は手元/CI、サイトは静的ビルド。サイトは `results/` を読むだけで API を叩かない
- **追記オンリー**: 過去の run は消さず、新しい run を積む。差分実行(下記)で API コストを抑える
- **モデルとハーネスを直交に扱う**: 「素のモデル単発呼び出し」と「Claude Code のような agentic ハーネス」は別の評価軸。両方を 1 級市民として表示する
- **agentic ループは MCP サーバー経由で外部エージェントへ委譲**: 自前で `LLM → render → feed back` を書かない。`render_openscad` / `submit_final` を提供する MCP サーバーを立て、Claude Code 等を起動して接続させる。これにより
  - エージェント側の計画力・自己修正力もまるごと評価対象になる
  - Cursor / Cline / 自作 SDK エージェント等を共通の境界面で比較できる
  - エージェントのバージョンアップに評価環境が追随しやすい

## 差分実行(signature ベース)

API 課金が嵩むので「変更があった組み合わせだけ流す」ことを必須とする。

### Run signature

各 run には `fingerprint` と、それを canonical JSON でハッシュ化した `signature` を持たせる。`fingerprint` には再現に必要な条件をすべて入れる:

- `taskHash`: 課題 YAML 全体の sha256
- `harness.kind`: `bare` | `external-agent`
- bare の場合: `provider`, `model`, `modelOptions`(temperature 等)
- external-agent の場合: `agent`, `agentVersion`, `maxTurns`, `allowedTools`, `modelHint?`, `subagents?`
  - **`subagents`**: ハーネスが内部で別エージェントを使う場合(例: メインエージェント Opus 4.7 + レンダリング結果のレビューを Haiku 4.5 のサブエージェントに任せる)、各サブエージェントの `name` / `model` / `provider?` / `role?` を順序付き配列として持つ。サブエージェントの差(例: モデル変更)もキャッシュ無効化のキーになる
  - run の `harness.subagents` 側にはサブエージェントごとの `invocations` / `tokens` / `cost_usd` がログとして残る
- `mcpServerVersion?`: 自前 MCP server のバージョン
- `openscadVersion`
- `promptTemplateHash`
- `schemaVersion`(fingerprint 仕様自体のバージョン)

`signature` が同じなら「同じ条件」とみなす。

### CLI

- `pnpm bench plan` — `bench-config.yml` の matrix × tasks を展開し、既存 run の signature と突合して **up-to-date / missing / stale** に分類して表示。**API は叩かない**
- `pnpm bench run` — missing/stale だけを実行。`--force`, `--filter`, `--samples N`
- `pnpm bench show <runId>` — meta/log を pretty 表示

### モデル指定の方針(全プロバイダ共通)

**dated snapshot や具体バージョン ID が公開されているモデルは必ずそれを使う**。エイリアス(`claude-opus-4-7`、`gpt-5`、`gemini-2.5-pro` 等)はプロバイダ側の都合で別スナップショットを指すように差し替わり得るが、その変化は API レスポンスからは検出できないため、エイリアスのまま使うと fingerprint も変わらず過去データとの比較が破綻する。

| Provider | 例 |
|---|---|
| Anthropic | `claude-haiku-4-5-20251001`、`claude-sonnet-4-5-20250929` |
| OpenAI | dated snapshot(例: `gpt-5-2025-09-15`)、または `system_fingerprint` をログに残す |
| Google | versioned ID(例: `gemini-2.5-pro-002`) |
| ローカル/OSS | hash 付き tag(例: `qwen3-coder:32b@sha256:...`) |

**dated suffix が未公開のモデル**(2026-04 時点の Anthropic `claude-opus-4-7` / `claude-sonnet-4-6` 等)は alias しか手段がなく、silent update を完全には検出できない制約を受け入れる。必要なら matrix エントリに `revision` フィールド(任意の文字列、fingerprint に乗る)を加えて手動で cache-busting する:

```yaml
- id: bare/claude-opus-4-7
  harness: { kind: bare }
  provider: anthropic
  model: claude-opus-4-7
  revision: "2026-04"   # 任意。silent update を疑った時に bump
```

将来課題: 固定プロンプトを定期的に流して出力ハッシュの drift を検出する仕組み(全プロバイダに同じ機構で適用できる)。

### サンプルとしてカウントする status

`results/` に書き出すのも plan の「up-to-date 判定」にカウントするのも、**モデルの実際の挙動を観測できた run のみ**:

- `success`(成功)
- `no_code`(モデルが SCAD を返さなかった)
- `render_error`(モデルが SCAD を返したが OpenSCAD でレンダーに失敗した)
- `submit_missing`(agentic ハーネスで `submit_final` が呼ばれずに終わった)

`api_error` / `timeout` は **ベンチマークの事前条件が壊れている**(API キー欠落、ネットワーク不通、レート制限など)状態であり、モデルの観測ではない。これらは `results/` に書き込まず、CLI の出力でのみ報告する。再実行で自動的にリトライされる。

### stale 判定の例

- 課題 YAML を編集 → 該当タスクの全エントリ stale
- `bench-config.yml` のモデル指定を上げた → そのエントリだけ stale
- claude-code を更新して `agentVersion` が変わった → external-agent エントリが stale
- openscad 更新 → 全件 stale(再レンダリング必要)

## ディレクトリ構成

```
vibe-openscad/
├── tasks/                       # 課題 YAML(難易度ティア別)
├── bench-config.yml             # 実行マトリクス
├── runners/                     # ベンチ実行スクリプト(Node/TS)
│   └── src/
│       ├── providers/           # 素の API 単発呼び出し用クライアント
│       ├── harnesses/           # bare / external-agent
│       ├── mcp/                 # MCP サーバー(render_openscad / submit_final)
│       ├── render.ts            # openscad CLI 呼び出し
│       ├── tasks.ts             # YAML ロード
│       ├── results.ts           # meta.json 書き出し/索引化
│       ├── matrix.ts            # bench-config.yml 展開
│       ├── signature.ts         # fingerprint → signature
│       ├── plan.ts              # 差分判定
│       ├── env.ts               # openscad/agent CLI のバージョン取得
│       ├── run.ts               # CLI エントリポイント
│       └── schema.ts            # Zod スキーマ
├── results/                     # 実行結果(コミット対象)
│   └── <task-id>/<run-id>/
│       ├── meta.json
│       ├── prompt.md
│       ├── final.{scad,stl,png}
│       ├── agent-log.jsonl      # external-agent のとき
│       └── iterations/NN/{scad,stl,png,note.md}
├── web/                         # Astro サイト
│   └── src/
│       ├── pages/{index,tasks/[id],runs/[id]}.astro
│       ├── components/StlViewer.ts
│       └── lib/results.ts
├── DESIGN.md / CLAUDE.md / README.md
└── .github/workflows/{ci,deploy}.yml
```

## データスキーマ

### 課題 YAML

```yaml
id: tier-1-cube-with-hole
tier: 1
title: 中央に貫通穴を持つ立方体
prompt: |
  OpenSCAD で 50mm 角の立方体の中央に直径 20mm の貫通穴を z 軸方向に開けたモデルを作成してください。
  完成したコード全体を ```openscad ... ``` で囲んで出力してください。
expected:
  bbox_mm: [50, 50, 50]
  manifold: true
```

### 実行マトリクス(`bench-config.yml`)

```yaml
defaults:
  samples: 1
  timeoutSec: 300
matrix:
  - id: claude-opus-bare
    harness: { kind: bare }
    provider: anthropic
    model: claude-opus-4-7
  - id: claude-opus-cc
    harness: { kind: external-agent, agent: claude-code, maxTurns: 8 }
tasks:
  - tier: 1
```

### `meta.json`

`fingerprint` と `signature` が再現キー。それ以外はログ用途。詳細は `runners/src/schema.ts` の Zod 定義を参照。

## 3D 表示

- 一覧: PNG サムネイル(OpenSCAD で固定アングルからレンダリング)
- 詳細: three.js + STLLoader を vanilla web component として埋め込む island。React-Three-Fiber 等は使わない(オーバーキル)
- `<model-viewer>` は STL 非対応のため不採用

## デプロイ

- GitHub Actions で `web/` を `astro build` → `wrangler deploy`(Workers Static Assets)
- `web/wrangler.toml` で `[assets] directory = "./dist"` を指定。`main` を持たない assets-only Worker
- ベンチ成果物は事前に `results/` にコミットされている前提(デプロイ中に API は叩かない)
- ※ 旧 Cloudflare Pages ではなく **Workers Static Assets** を使用(2026 年時点で Workers が推奨)

## 主な技術選定の根拠

- **pnpm workspace モノレポ**: `runners` と `web` の依存ツリーを分離しつつ Zod スキーマを将来 `shared/` に切り出しやすい
- **Astro + 静的ビルド**: 課題ごとに独立した詳細ページを大量に生やすのが得意。3D ビューアは必要なページだけ island
- **追記オンリーの `results/`**: 履歴が見えるほうがベンチマークとして価値があるため
- **MCP を agentic 境界面に**: ハーネスを別個のシステム(claude-code の CLI 等)として外部化することで、それ自体を評価対象にできる

## Iteration: 各 step を独立した benchmark run として扱う

レンダリング結果を見せてモデルに修正させる loop は、**1 step = 1 run** として
扱う。chain は bench-config.yml の matrix entry を `iterateFrom` で繋いで表現
し、harness 自体は単一の `bare` のみ。

```yaml
- id: bare/claude-sonnet-4-6
  harness: { kind: bare }
  provider: anthropic
  model: claude-sonnet-4-6
- id: iter-png-1/claude-sonnet-4-6
  harness:
    kind: bare
    iterateFrom: bare/claude-sonnet-4-6
    iteration: { kind: render-png-feedback }
  provider: anthropic
  model: claude-sonnet-4-6
- id: iter-png-2/claude-sonnet-4-6
  harness:
    kind: bare
    iterateFrom: iter-png-1/claude-sonnet-4-6
    iteration: { kind: render-png-feedback }
  ...
```

各 run の `meta.parentRunId` で前段にリンクし、UI は run 詳細ページで親/子を
表示、ダッシュボードと `/harnesses/iter-png/` で chain として束ねて見せる。

**この設計を採用した理由**:

- chain の枝分かれが自然に書ける(同じ root bare から render-png-feedback と
  error-text-feedback の 2 系列を分岐させても root を再実行不要)
- 各 step が独立した sample なので、同じ depth の複数試行・別モデルとの depth
  比較が普通の `samples` 軸で扱える
- iteration 履歴を「親 run の `final.{scad,png}` を読み込む」だけで再現できる
  ので、artifact 重複が無い

### iteration strategy(`iteration.kind`)

`iterateFrom` を持つ entry は `iteration` フィールドに戦略を指定する。
discriminated union で、新しい variant 追加が既存 fingerprint を壊さない:

- `{ kind: render-png-feedback }` — 親の `final.png` を画像として multimodal で
  渡し、修正したコードを要求(現在実装している唯一)
- `{ kind: error-text-feedback }` — 画像なしで親 run のエラー文字列だけ渡す。
  コスト圧縮・テキストのみ反復のベースライン(配線は schema にあるが、harness
  実装は親が `success` の chain しか見ていないので未配線)

将来追加するなら同 union の variant として:
`{ kind: render-png-multi-angle, angles: [...] }`、`{ kind: evaluator-judge,
critic_model: "..." }` 等。

### stale 連鎖

子 entry の fingerprint には `parentSignature`(親 entry の signature)が
埋め込まれる。親の model・options・revision 等を変えると親 signature が変わり、
連鎖して子 signature も変わる → `bench plan` で stale 判定される。
`parentSignature` は optional で、単発 bare の signature は iteration 導入前と
**byte-identical**(既存 cache を壊さない)。

### 反復ステップ数を増やしたくなったら

bench-config.yml に `iter-png-4/...`, `iter-png-5/...` を追記して `bench run`。
既存の 1〜3 はキャッシュ済みなので追加分のみ走る。多角的に分岐させたければ
`iterateFrom: bare/...` を直接指す別 strategy 系列(例 error-text-1/...)を
追加するだけで root bare の再実行不要。

### 単独成果物のレイアウト

各 run dir は単発 bare と同じ:
`results/<task>/<runId>/{meta.json, prompt.md, final.scad, final.stl, final.png, agent-log.jsonl?}`。
chain step では `meta.parentRunId` だけ追加で入る。`iterations/NN/` のような
入れ子ディレクトリは廃止。

## 自動評価について(将来課題)

bbox や manifold チェックといった単純な属性検証では、3D 空間認識の品質を測るにはほぼ意味がない(寸法が合っていても形が破綻している、その逆もある)。

将来的には **視覚回帰(visual regression)テスト** に近い形で取り組む想定:

- 各課題に「あるべき見た目」を表す参照画像/STL を用意するか、複数モデル間で相対比較する
- レンダリング結果を画像として比較(perceptual diff、または vision LLM ジャッジ)
- 「同じ条件で同じ結果が出る」ことだけ保証する形(回帰検出に重きを置く)

実装は別タスク。この想定があるので、現時点の課題 YAML には `expected: {bbox_mm, manifold}` のような自動検証用フィールドは置かない(中途半端な仕様の固定化を避ける)。

## 将来検討する論点

- `results/` の肥大化対策(Tier 2 以降 / agentic で iteration が増えた場合): Git LFS か R2/S3 への切替
- agentic 評価の公平性: max-turns / タイムアウト / 許可ツール / `render_openscad` 呼び出し回数の上限をハーネス間で揃える
- OpenSCAD 自体のバージョン互換: openscad メジャー更新時は全 run を stale 化して再レンダリングする
