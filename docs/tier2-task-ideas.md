# tier-2 タスク候補(LLM の CAD/3D 推論の弱点ベース)

## 出典(verify 済み)

- **BlenderLLM** (arXiv:2412.14203, Du et al. 2024) — Blender Python script 生成の自己改善ベンチ。"対称性・軸合わせ" と "negative space reasoning" が弱点。
- **3DSRBench** (arXiv:2412.07825, Ma et al. ICCV 2025) — 3D 空間推論 VQA 2,772 問。axis-of-rotation で GPT-4o ≈30-40%、uncommon 6D 視点で崩壊。
- **SpatialEval** (arXiv:2406.14852, Wang et al. NeurIPS 2024)— "Is A Picture Worth A Thousand Words?"。VLM が LLM 以下になるケースもあり。
- **Text2CAD** (arXiv:2409.17106, NeurIPS 2024 Spotlight) — DeepCAD 170K モデル、抽象→詳細 prompt の autoregressive 生成精度。
- **3D-PreMise** (arXiv:2401.06437, Yuan et al. 2024) — シャープ特徴 + パラメトリック制御の同時生成が困難。industrial shapes。
- **CAD-LLM** (ML4CD workshop 2023, Wu et al.) — T5-770M で 2D スケッチ生成。マニフォールド/薄壁。
- **CADCodeVerify** (arXiv:2410.05340, ICLR 2025) — VLM フィードバックで CAD コード検証。自己検証の限界。
- **AIDL: Solver-Aided Hierarchical Language** (arXiv:2502.09819) — procedural CAD で **spatial reasoning と long-range planning** が苦手と明記。
- **EvoCAD** (arXiv:2510.11631) — Euler 特性ベースの位相メトリクス(Self-Intersection Ratio 等)。
- **LLM4CAD** survey (arXiv:2505.08137)
- r/openscad / OpenSCAD forum 2024-2025 / Twitter/X(コミュニティ観察)

**注**: OpenSCAD 専用の公的ベンチマークは未発見。ねじ/嵌合/薄壁/helical 専用ベンチも空白(本プロジェクトの独自性)。

## 弱点軸(出典マッピング)

| # | 弱点 | 出典 | OpenSCAD への体現例 |
|---|---|---|---|
| 1 | シャープ特徴 + パラメトリック制御 | 3D-PreMise | 寸法指定された機能形状(ねじ穴等) |
| 2 | 空間推論(向き、左右、6D 視点) | SpatialEval, 3DSRBench | "+X 側に handle"、軸方向指定 |
| 3 | 長距離プランニング / 階層構造 | AIDL | 多段反復 + 多軸 transform、組立 |
| 4 | 構造的正しさの自己検証 | CADCodeVerify | (vision LLM judge は別系統で対応) |
| 5 | 位相整合性(穴・自己交差・dangling edge) | EvoCAD, Text2CAD | マニフォールド維持、`difference` overlap |
| 6 | シーケンシャル design history | Text2CAD | 嵌合する複数部品(別 module) |

## tier-2 タスク候補 8 件

各 prompt は実装済みのまま再掲。出典との対応 (axes) を明示。

### 1. Hex Bolt M8x30(六角ボルト)
- **prompt**: "Generate OpenSCAD for an M8 hex bolt: hex head across-flats 13mm, head height 5.3mm, shank diameter 8mm, shank length 30mm, axis along +Z, head at origin."
- **測定 axes**: 1 (シャープ特徴+寸法) + 2 (軸指定)
- **期待**: 全高 35.3mm、頭 13mm AF

### 2. Threaded Knob with 4 finger grips
- **prompt**: "Knob, 30mm dia, 12mm tall, with 4 cylindrical finger scallops (8mm dia) cut equally around the perimeter."
- **測定 axes**: 3 (反復+三角関数) + 5 (difference overlap)
- **期待**: 4 つの scallop が 90 度ごと、対称

### 3. L-bracket with countersunk holes
- **prompt**: "90-degree L-bracket, 50x50x40mm, 3mm wall, two M4 countersunk holes on each face, holes 10mm from edges."
- **測定 axes**: 2 (鏡像対称) + 3 (相対座標) + 5 (段付き穴)
- **期待**: 2 面 × 2 穴 = 4 穴、皿は外側

### 4. Honeycomb plate
- **prompt**: "Flat plate 60x60x3mm with hexagonal through-holes (6mm across-flats, 8mm pitch) tiled across it."
- **測定 axes**: 3 (タイリング) + 5 (隣接 hex の重なり回避)
- **期待**: 2 行ごとに半ピッチずれ、すべて貫通

### 5. Snap-fit box with lid (clearance 0.2mm)
- **prompt**: "Rectangular box 40x30x20mm, wall 2mm, with a press-fit lid that has a 0.2mm clearance lip around the inner perimeter."
- **測定 axes**: 1 (公差) + 6 (複数部品 module)
- **期待**: lid を被せると入る寸法関係

### 6. Helical gear stub (8 teeth, twist 30°)
- **prompt**: "Cylindrical gear blank 25mm dia, 10mm tall, 8 trapezoidal teeth, total helical twist 30 degrees over the height."
- **測定 axes**: 1 (歯形) + 3 (周方向反復) + 5 (helical 構造)
- **期待**: 上下端面で 30° ずれた歯

### 7. Spiral staircase (12 steps around a central pole)
- **prompt**: "Spiral staircase: central pole dia 30mm height 240mm; 12 fan-shaped steps, each 20mm thick, 100mm long, rotated 30 degrees per step climbing 20mm."
- **測定 axes**: 3 (多軸 transform 反復) + 5 (干渉回避)
- **期待**: 上から見て一周、高さ 240mm

### 8. Mug with offset handle (left/right specific)
- **prompt**: "Mug, OD 80mm, ID 70mm, height 90mm, with a D-shaped handle attached to the +X side, handle inner clearance 30mm tall by 25mm wide."
- **測定 axes**: 2 (向き指定) + 5 (handle と本体の union マニフォールド)
- **期待**: handle が本体と確実に union され、内側が抜けている

## tier-3 候補(参考)

- 干渉なしで噛み合う 2 枚の平歯車ペア(モジュール一致)
- 内部に格子サポートを持つ閉じたソリッド(マニフォールド維持が困難)
- ねじ山付き M10 ボルト&ナット(リード一致、嵌合)— 軸 1+5+6 同時
- 薄壁シェル + 補強リブ(壁厚 0.8mm 程度、内側に 4 リブ)— 軸 1+5
