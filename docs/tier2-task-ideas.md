# tier-2 タスク候補(LLM の 3D/空間推論の弱点ベース)

調査出典: BlenderLLM (arXiv:2412.14203) / 3DSRBench (arXiv:2412.07825) /
SpatialEval (NeurIPS 2024) / Text2CAD (NeurIPS 2024) / CAD-LLM (Wu 2023) /
3D-PreMise (Yuan 2024) / r/openscad / OpenSCAD forum 2024-2025。

## 既知の弱点パターン

- **対称性・軸合わせ・座標オフセット**:`translate` の符号ミス、中心配置の取り違え (BlenderLLM, 3D-PreMise)
- **ブール演算 (特に `difference` の overlap)**:穴を空ける際に subtractor を貫通させず Z-fighting (BlenderLLM)
- **マニフォールド性・薄壁・self-intersection**:壁厚 0、面が共有されないソリッド (CAD-LLM, Text2CAD)
- **回転軸の合成順**:`rotate([a,b,c])` の順序ミス、3DSRBench の axis-of-rotation で GPT-4o 30〜40%
- **相対座標 vs 絶対座標**:入れ子 `translate` の親子関係が壊れる (SpatialRGPT/SpatialBot)
- **数量・整列**:円周配置で半径 / 個数 / 位相がズレる (MMMU spatial, CharXiv)
- **嵌合公差**:オス/メスのクリアランスを 0 にする (HN/r/openscad)
- **曲面と CSG の混在**:`minkowski` / `hull` 系が顕著に弱い (BlenderEval)
- **helical 構造**:`linear_extrude(twist=)` の twist 方向と pitch (Text2CAD, CADBench)
- **左右・鏡像**:`mirror([1,0,0])` の選択ミス、3DSRBench mirror で chance level (3DSRBench)
- **`hull()` 発想の欠如・counterbore を一段で書こうとする** (Twitter/X 2024 からの観察)

## tier-2 タスク候補 8 件

各タスクは 2 軸以上の弱点を同時に突く。

### 1. Hex Bolt M8x30(六角ボルト)
- **prompt**: "Generate OpenSCAD for an M8 hex bolt: hex head across-flats 13mm, head height 5.3mm, shank diameter 8mm, shank length 30mm, axis along +Z, head at origin."
- **測定**: 軸合わせ + 六角の `cylinder($fn=6)` 向き + 寸法整合
- **期待**: 全高 35.3mm、頭 13mm AF

### 2. Threaded Knob with 4 finger grips
- **prompt**: "Knob, 30mm dia, 12mm tall, with 4 cylindrical finger scallops (8mm dia) cut equally around the perimeter."
- **測定**: 円周等配 + difference + 三角関数
- **期待**: 4 つの scallop が 90° ごと、対称

### 3. L-bracket with countersunk holes
- **prompt**: "90-degree L-bracket, 50x50x40mm, 3mm wall, two M4 countersunk holes on each face, holes 10mm from edges."
- **測定**: 相対座標 + countersink(段付き穴)+ 鏡像対称
- **期待**: 2 面 × 2 穴 = 4 穴、皿は外側

### 4. Honeycomb plate
- **prompt**: "Flat plate 60x60x3mm with hexagonal through-holes (6mm across-flats, 8mm pitch) tiled across it."
- **測定**: 2D タイリング(オフセット行)+ 貫通 difference
- **期待**: 2 行ごとに半ピッチずれ、すべて貫通

### 5. Snap-fit box with lid (clearance 0.2mm)
- **prompt**: "Rectangular box 40x30x20mm, wall 2mm, with a press-fit lid that has a 0.2mm clearance lip around the inner perimeter."
- **測定**: 嵌合公差 + ネガティブスペース + 2 部品を別 module で
- **期待**: lid を被せると入る寸法関係

### 6. Helical gear stub (8 teeth, twist 30°)
- **prompt**: "Cylindrical gear blank 25mm dia, 10mm tall, 8 trapezoidal teeth, total helical twist 30 degrees over the height."
- **測定**: `linear_extrude(twist=)` + 周方向反復 + 歯形
- **期待**: 上下端面で 30° ずれた歯

### 7. Spiral staircase (12 steps around a central pole)
- **prompt**: "Spiral staircase: central pole dia 30mm height 240mm; 12 fan-shaped steps, each 20mm thick, 100mm long, rotated 30 degrees per step climbing 20mm."
- **測定**: 回転 + 平行移動の複合、極座標的反復
- **期待**: 上から見て一周、高さ 240mm

### 8. Mug with offset handle (left/right specific)
- **prompt**: "Mug, OD 80mm, ID 70mm, height 90mm, with a D-shaped handle attached to the +X side, handle inner clearance 30mm tall by 25mm wide."
- **測定**: tier-1 mug の上位互換 — 左右指定 + handle のトーラス系曲面 + マニフォールド結合
- **期待**: handle が本体と確実に union され、内側が抜けている

## tier-3 候補(参考)

- 干渉なしで噛み合う 2 枚の平歯車ペア(モジュール一致)
- 内部に格子サポートを持つ閉じたソリッド(マニフォールド維持が困難)
- ねじ山付き M10 ボルト&ナット(リード一致)
