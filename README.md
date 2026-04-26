# vibe-openscad

LLM の 3 次元空間認識を OpenSCAD で測るベンチマーク。複数のモデルとハーネス(Claude Code 等)に同じ課題を解かせ、結果を Web サイトで横並び比較する。

## 何を測るか

- **モデル単独(`bare`)**: API を 1 回叩いて出てきた SCAD をそのままレンダリング
- **ハーネス付き(`external-agent`)**: Claude Code 等のエージェントを立ち上げ、自前 MCP サーバーが提供する `render_openscad` / `submit_final` を介して自律的に SCAD を書き直しながら最終解を出す

両者を別軸として表示する。

## 課題

`tasks/` 以下に難易度ティア別に YAML で定義する。例:

```yaml
id: tier-1-cube-with-hole
tier: 1
title: 中央に貫通穴を持つ立方体
prompt: |
  OpenSCAD で 50mm 角の立方体の中央に直径 20mm の貫通穴を z 軸方向に開けたモデルを作成してください。
expected:
  bbox_mm: [50, 50, 50]
  manifold: true
```

## 使い方

```bash
pnpm install
pnpm bench plan                                  # 何が走るか確認(API は叩かない)
ANTHROPIC_API_KEY=... pnpm bench run             # 差分のみ実行
pnpm --filter web dev                            # ローカルでサイトを見る
```

詳細は [DESIGN.md](./DESIGN.md) と [CLAUDE.md](./CLAUDE.md) を参照。

## 開発

- TypeScript + Vitest による TDD
- pnpm workspace モノレポ(`runners` / `web`)
- ベンチ実行は **差分実行(signature ベース)** で、変更があった組み合わせだけ走る
- デプロイ先: Cloudflare Workers Static Assets
