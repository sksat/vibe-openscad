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
- `pnpm bench run` — missing/stale だけを実行。`--force`, `--filter`, `--samples N`, `--concurrency N` (`-j N`), `--concurrency-<provider> N`
- `pnpm bench show <runId>` — meta/log を pretty 表示

### 並列実行

`bench run` は API 待ちで blocking している時間が大半なので、並列化が時間短縮にすごく効く。`runners/src/scheduler.ts` で「グローバル上限 + bucket(provider)毎上限 + dependsOn DAG」を扱う薄いスケジューラを使う。

- **デフォルト**: `defaults.concurrency.global = 4`、`defaults.concurrency.perProvider.anthropic = 2`(他 provider は無制限)。Anthropic は他社より rate limit が厳しい(tier 1 で 50 RPM、ITPM/OTPM もタイト)ので明示的に絞る
- **CLI 上書き**: `-j 8` で global、`--concurrency-openai 6` で provider 別
- **iteration chain は自動で順序保証**: 親が同じ todo に居れば dependsOn に登録、居なければ即起動
- **bucket cap で詰まった場合**: 別 bucket を試して deadlock 回避
- **失敗の扱い**: 1 つ失敗しても in-flight は完走させる(benchmark 用途では情報量重視)
- **直列実行が必要なら** `-j 1`、または bench-config.yml で `concurrency.global: 1` を明示

依存サイクルや不明な dependency は build 前に検出して reject する。

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
# テキストのみ(tier-1〜3 の標準)
id: tier-1-cube-with-hole
tier: 1
title: 中央に貫通穴を持つ立方体
prompt: |
  OpenSCAD で 50mm 角の立方体の中央に直径 20mm の貫通穴を z 軸方向に開けたモデルを作成してください。
  完成したコード全体を ```openscad ... ``` で囲んで出力してください。
```

```yaml
# 内部 id は signature fingerprint の安定化のため不変だが、URL は人間が
# 読みやすい名前にしたい。両者を両立するため optional な `slug` フィールド。
# 未指定時は id から `tier-N-` prefix を剥がしたものを使う。
id: tier-1-mug
slug: simple-mug
tier: 1
title: 取手付きマグカップ
prompt: |
  ...
```

```yaml
# tier-4 vision タスク: PDF データシートのページを画像として LLM に
# 渡し、3D モデルを起こさせる。`pdf-page` ハーネスが pdftoppm で
# 該当ページを PNG に切り出して provider に投げる。
id: tier-4-gp2y0d413k
slug: gp2y0d413k
tier: 4
title: 距離センサ GP2Y0D413K0F の外形モデリング
prompt: |
  添付のデータシート 2 ページ目を読んで OpenSCAD で外形をモデリングしてください...
pdf_source:
  url: https://jp.sharp/products/device/doc/opto/gp2y0d413k_e.pdf
  pages: [2]
```

`prompt_images: [path1, path2]`(YAML からの相対パス)も同じく vision 入力としてサポート。loader が読み込み時に sha256 を計算して `prompt_image_hashes` に詰める。`taskHash` には path / Buffer は入れず content hash のみを乗せ、マシン間で signature が揺れないようにする。

### URL スラグ

- `/run/<runId>` — 単一 run 詳細
- `/task/` — task 一覧
- `/task/<slug>` — task 詳細(slug は YAML の `slug:` か、無ければ id から `tier-N-` prefix を剥がしたもの)
- `/task/<slug>/<model>` — (task, model) 詳細
- `/models` — モデル比較リーダーボード(一覧)
- `/models/<id>` — モデル別ページ
- `/harnesses/<id>` — ハーネス別ページ

URL に `tier-` prefix を含めない理由: tier は将来再編する可能性があるが、URL は安定していてほしい。一方で内部 id は signature fingerprint に効くので不用意に変えたくない。両立するため slug を分離した。同 slug 衝突は web ビルド時に弾く。

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

## モデルカタログ(`models.yml`)

**モデル固有の事実は `models.yml` に集約し、コードには置かない。**

| 置くもの | 置かないもの |
|---|---|
| `rate`(\$/Mtok)、`vision`、provider 既定の `effort` / `thinking`、命名規則から外れる場合の `label` / `sort` | 実行条件(どの variant を回すか、`max_tokens`、`temperature` 等) |

実行条件は `bench-config.yml` の matrix 側の担当。「モデルを見れば決まる事実」と
「今回どう回すか」を別ファイルに分けている。

### なぜ分離したか

以前はモデル 1 つ追加するのに **4 箇所のコード**(`pricing.ts` の価格表、
`capabilities.ts` の vision 正規表現、`web/src/lib/dataset.ts` の既定 effort と
既定 thinking)と、**それぞれに対応する手書きテスト** を触る必要があった。
データがロジックに埋まっているせいで、本質的には「表に 1 行足す」だけの作業が
コード変更として扱われ、モデル追加のたびにテストを書き足す運用になっていた。

カタログに集約したことで **モデル追加は原則データだけで完結する**
(`models.yml` に 1 エントリ + `bench-config.yml` に matrix 行)。

### 解決規則: prefix × フィールド単位の最長一致

キーは **モデル id の prefix**。あるモデル id に対して prefix が一致する
エントリをすべて集め、**短い順に重ねて**マージする(長い prefix が同名
フィールドを上書きする)。

```
gpt-5      : { vision: true, effort: medium, rate: 1.25/10 }
gpt-5.4    : { rate: 2/16 }
→ gpt-5.4-2026-03-05 は rate=2/16、vision と effort は gpt-5 から継承
```

これで 2 つの性質が同時に手に入る:

- **dated snapshot が alias を自動で引き継ぐ** — `claude-haiku-4-5-20251001` は
  `claude-haiku-4-5` のエントリに解決される。将来モデルに dated suffix が
  付いてもカタログを触らなくてよい
- **族の既定値と個体の上書きを同じ仕組みで書ける** — `gemini-` に vision を
  一度書けば全 Gemini に効き、世代ごとのエントリは価格だけ書けばよい

`effort: null` のような **明示 null は「その軸が存在しない」という宣言**であり、
未宣言(キーが無い)とは区別する。Haiku 4.5 は `effort: null`(API が
`output_config.effort` を拒否する)、OpenAI は thinking を effort に内包するので
`thinking` を宣言しない、という違いをそのまま表現できる。

### 網羅テストで手書きテストを置き換える(不変条件)

モデル追加時に **新しいテストを書かない** かわりに、データ駆動の網羅テストが
`bench-config.yml` の matrix を走査して穴を検出する:

- `runners/src/models.test.ts` — matrix の全 (provider, model) がカタログで
  解決でき、`vision` が宣言され、クラウド provider なら `rate` を持ち、
  effort / thinking 軸を持つ provider ではその軸が宣言されていること
- `web/src/lib/model-coverage.test.ts` — 全モデルが UI でラベル付けでき、
  セルフホスト以外は既知の族バケツにソートされること(素の id が
  そのまま表示されたり並び順が末尾に落ちたりしないこと)

つまり **カタログへの登録漏れは CI で落ちる**。逆に言うと、これらの網羅テストを
弱めるとモデル追加時の唯一のガードが消えるので、緩める変更は慎重に。

個々のモデルの価格や vision 可否を `*.test.ts` に再度書かないこと(カタログと
テストで同じ値を二重管理することになり、まさに分離した意味が無くなる)。
テストが固定するのは **解決規則**(dated snapshot の継承、長い prefix が勝つ、
provider を跨がない)と計算式。

### `label` / `sort` を書くのはどういうときか

web 側はモデル id の命名規則からラベルと並び順を導出する
(`claude-opus-5` → 「opus 5」、`gemini-3.8-flash` → 「flash 3.8」)ので、
素直な id なら何も書かなくてよい。カタログの `label` / `sort` は
**パターンマッチが外れたときのフォールバック**で、`gpt-5.6-sol` のように
世代とティアが別語彙になっている id のために用意してある。

## ハーネス

### `bare`

provider を 1 回叩いて応答から SCAD を抜き出すだけのハーネス。tier-1〜3 の標準。`task.prompt_images` か `prompt_image_data` があれば single-shot でも text + image content parts で送る(vision 対応モデル限定、`matrix.ts` が plan 段階で非対応モデルを除外)。

iteration(`iterateFrom`)が設定されていれば bare のままで前段 run の出力(SCAD + PNG / error テキスト)を feedback ターンとして付け加えて 1 回呼ぶ — 詳細は後述「Iteration」節。

### `pdf-page`

`bare` の前段に **PDF preprocessing** を挟むハーネス。`task.pdf_source = { url, pages }` の URL を取りに行き、`pdftoppm` で指定ページを PNG に切り出して、bare 同形の context に inject して `runBare` に委譲する。tier-4 のデータシート起こしタスクで使う。

- PDF キャッシュ: `~/.cache/vibe-openscad/pdf/<sha-of-url>.pdf`(disk cache、再 plan / 再 run で再ダウンロードしない)
- fingerprint stability: PDF 中身の sha256 を `pdf_source_hash` に乗せる。URL は環境依存なので除外、ページ番号と中身ハッシュだけが taskHash に効く
- 非 vision モデル × pdf_source タスクの組合せは `expandMatrix` で除外。逆に `pdf-page` ハーネス × `pdf_source` 無し task も意味が無いので除外

### `external-agent`(将来)

Claude Code / Cursor / 自作 SDK エージェント等を **MCP 経由で** 動かして、レンダリング結果を見ながら自己修正させる。`render_openscad` / `submit_final` を提供する MCP サーバを別プロセスで立てて、エージェント CLI を起動して接続する。これにより:

- エージェント側のハーネス品質(計画力・自己修正)も評価対象に含められる
- 同じ MCP に異なるエージェントをぶら下げて横並び比較できる

実装は別タスク。この想定があるので harness 種別は最初から union(`bare` | `pdf-page` | `external-agent`)に切ってある。

## 3D 表示

- 一覧: PNG サムネイル(OpenSCAD で固定アングルからレンダリング)
- 詳細: three.js + STLLoader を vanilla web component として埋め込む island。React-Three-Fiber 等は使わない(オーバーキル)
- `<model-viewer>` は STL 非対応のため不採用
- **パラメトリック 3D ビューア**: SCAD の top-level 変数(数値・bool)をスライダーで動かすと openscad-wasm で再レンダして即時反映。openscad-wasm の `callMain` が同期 blocking で UI を凍らせるため Web Worker に分離。`console.error.bind(console)` で stderr が固定参照になる Emscripten ラッパーの仕様に合わせて、worker 起動時に console を差し替えて bind 経由で実エラーメッセージをキャプチャする(さもないと exit code の数値だけが見える)
- **ダッシュボード階層表示**: `(harness × provider × model)` を二段ネスト表示し、`harness > provider > model` ↔ `provider > harness > model` を localStorage に保存して全 task row 共有。両方を SSR してハードコード CSS の `[hidden]` で切り替える(client 側で DOM を組み直さない)

## モデル比較(`/models` leaderboard)

ダッシュボード(`/`)は **タスク先頭**で、1 タスクを行に、その中のモデルを
harness × provider で 2 段ネストして並べる。これは「あるタスクを全モデルでどう
解いたか」を見るのに向くが、**モデル同士の横断比較**には向かない(同じタスク内
でも provider が違うとサブボックスが分かれて opus と gpt-5 が隣り合わない)。

そこを埋めるのが `/models` リーダーボード。**モデル先頭**で 1 モデルを 1 行に
畳み、成功率・平均コスト・平均レイテンシで横並び/ソートできる。右端にタスク別の
レンダ帯(全行で列が縦に揃う)を置き、クリックで拡大ライトボックス
(←→ で同一モデルの別タスク、↑↓ で同一タスクの別モデルへ移動)。

### 集計のベースライン軸(不変条件)

リーダーボードの headline 指標は **provider 既定の単発 bare run**
(matrixId 先頭セグメントが厳密に `bare` のもの)だけで計算する。これがモデル
横断で最も apples-to-apples な比較になる(全体方針「素のモデル単発呼び出しを
1 級市民として扱う」に対応)。次は **意図的に除外**する:

- effort variant(`bare-high/...` 等)・thinking variant(`bare-think-off/...` の
  ように 2 セグメント以上の head)
- iteration chain step(`iter-png-1/...`)
- external-agent

判定 `isBaselineRun()` は `bare-<...>` を正規表現で個別に弾くのではなく
**「head === `bare`」の allow-list** で通す。`bare-think-off` のような複合
セグメント variant が将来増えても baseline に誤って混入しない(ここを
regex の deny-list にすると新 variant のたびに漏れる、というのが実装上の罠)。

variant / iteration を含めた深掘りは各モデル行のリンク先 `/models/<id>`
(task × variant グリッド)に委ねる。

**task 軸**は baseline(bare)run が成立しうるタスクだけにする。`pdf_source`
タスクは `pdf-page` harness 専用で planner(`matrix.ts`)が bare を一切
スケジュールしないため、リーダーボードからは除外する(さもないと全モデル
永久に空列になり `x/y task` 分母も水増しされる)。`prompt_images` の text
タスクは vision モデルが bare で走るので残す。

**sample 集計**は (model, task) ごとに **最新 baseline run と同一 `signature`
の run だけ**を pool する。サムネには最新 1 枚を出すが、成功率・平均コスト・
平均レイテンシは同 signature の全サンプルで平均する。これにより:

- `samples>1` で最新サンプル 1 件に依存しない(4 失敗 → 1 成功を 100% と
  誤表示しない)
- stale で再実行して signature が変わった場合、旧 signature の run は集計から
  外れる(古い失敗を引きずらない)

`samples:1` の現データでは「最新 1 件」と一致するので出力は不変。成功率の
分母はタスク数ではなく **sample 数**(`successCount / sampleCount`)。

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
