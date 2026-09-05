// =====================================================
//  L 字金具 (L-bracket)  /  M4 皿穴 × 4
//  内側コーナー = 原点
//  水平フランジ : +Y 方向 / 垂直フランジ : +Z 方向
// =====================================================

$fn = 64;

// ---------- パラメータ ----------
W       = 50;    // 幅 (X 方向) : 両フランジ共通
D       = 40;    // 水平面の奥行き (+Y)
H       = 40;    // 垂直面の高さ  (+Z)
T       = 3;     // 板厚

HOLE_D  = 4.5;   // 貫通穴 Φ4.5 (M4 用)
CSK_D   = 8;     // 皿座面 Φ8
CSK_H   = 2;     // 皿座面深さ 2
EDGE    = 10;    // 面の縁から穴中心までの距離

EPS     = 0.01;  // 差分演算用の微小値

XOFF    = W/2 - EDGE;   // 穴の左右オフセット = ±15

// ---------- 皿穴モジュール ----------
// z = 0 が外側表面(ボルト頭が当たる側)、材料は +Z 側に厚さ t
module countersunk_hole(t = T) {
    // 貫通穴
    translate([0, 0, -EPS])
        cylinder(d = HOLE_D, h = t + 2*EPS);
    // 皿座面(円錐) : 表面で Φ8 → 深さ 2mm で Φ4.5
    cylinder(d1 = CSK_D, d2 = HOLE_D, h = CSK_H);
    // 表面をきれいに抜くための微小延長
    translate([0, 0, -EPS])
        cylinder(d = CSK_D, h = EPS);
}

// ---------- 本体 ----------
difference() {
    union() {
        // 水平フランジ : 内面 z = 0、外面 z = -T、+Y へ 40mm
        translate([-W/2, 0, -T])  cube([W, D, T]);
        // 垂直フランジ : 内面 y = 0、外面 y = -T、+Z へ 40mm
        translate([-W/2, -T, 0])  cube([W, T, H]);
        // 外側コーナー部の充填
        translate([-W/2, -T, -T]) cube([W, T, T]);
    }

    // --- 水平面の皿穴 (外側 = 下面 z = -T、+Z へ貫通) ---
    for (x = [-XOFF, XOFF])
        translate([x, D/2, -T])
            countersunk_hole();

    // --- 垂直面の皿穴 (外側 = 背面 y = -T、+Y へ貫通) ---
    for (x = [-XOFF, XOFF])
        translate([x, -T, H/2])
            rotate([-90, 0, 0])
                countersunk_hole();
}