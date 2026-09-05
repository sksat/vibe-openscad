// ============================================================
//  L 字金具 (L-bracket) / M4 皿穴 4 箇所
//  内側コーナー = 原点
//  水平フランジ: +Y 方向へ 40mm / 垂直フランジ: +Z 方向へ 40mm
// ============================================================

$fn = 64;

// ---- 寸法パラメータ ----
width       = 50;    // 幅 (X 方向, 両フランジ共通)
depth       = 40;    // 水平フランジの奥行き (+Y)
height      = 40;    // 垂直フランジの高さ (+Z)
thickness   = 3;     // 板厚

// ---- 皿穴パラメータ (M4) ----
hole_d      = 4.5;   // 貫通穴径
csk_d       = 8;     // 皿座面径
csk_depth   = 2;     // 皿座面深さ
edge_offset = 10;    // 左右の縁から穴中心までの距離

eps = 0.01;          // 面の重なり回避用

// ------------------------------------------------------------
//  本体
// ------------------------------------------------------------
module bracket_body() {
    // 水平フランジ: Z ∈ [-t, 0], Y ∈ [-t, depth]  (上面 Z=0 が内側)
    translate([-width / 2, -thickness, -thickness])
        cube([width, depth + thickness, thickness]);

    // 垂直フランジ: Y ∈ [-t, 0], Z ∈ [-t, height] (前面 Y=0 が内側)
    translate([-width / 2, -thickness, -thickness])
        cube([width, thickness, height + thickness]);
}

// ------------------------------------------------------------
//  皿穴 (ローカル座標)
//   z = 0 が外側表面 (ボルト頭側)、+Z 方向が板の内部 (厚さ t)
// ------------------------------------------------------------
module countersunk_hole(t = thickness) {
    // 貫通穴 Φ4.5
    translate([0, 0, -eps])
        cylinder(h = t + 2 * eps, d = hole_d);

    // 皿座面 (円錐): 表面で Φ8 → 深さ 2mm で Φ4.5 に収束
    // 表面のわずかに外側から開始して同一平面の重なりを避ける
    translate([0, 0, -eps])
        cylinder(h  = csk_depth + eps,
                 d1 = csk_d + (csk_d - hole_d) / csk_depth * eps,
                 d2 = hole_d);
}

// ------------------------------------------------------------
//  穴の配置
//   各面の中心線上、左右の縁から 10mm 内側 (X = ±15mm)
// ------------------------------------------------------------
module holes() {
    hx = width / 2 - edge_offset;

    for (x = [-hx, hx]) {
        // 水平フランジ: 外側表面 = 下面 (Z = -t)、皿座面は下向き
        translate([x, depth / 2, -thickness])
            countersunk_hole(thickness);

        // 垂直フランジ: 外側表面 = 背面 (Y = -t)、皿座面は -Y 向き
        translate([x, -thickness, height / 2])
            rotate([-90, 0, 0])
                countersunk_hole(thickness);
    }
}

// ------------------------------------------------------------
//  組み立て
// ------------------------------------------------------------
module l_bracket() {
    difference() {
        bracket_body();
        holes();
    }
}

l_bracket();