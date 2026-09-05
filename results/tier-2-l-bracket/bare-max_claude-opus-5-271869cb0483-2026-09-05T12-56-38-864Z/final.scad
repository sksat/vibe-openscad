// ============================================================
//  L-bracket (L字金具) + M4 皿穴 4個
//  内側コーナー = 原点  /  水平面 : +Y 方向  /  垂直面 : +Z 方向
// ============================================================

$fn = 96;

/* ---------------- パラメータ ---------------- */
W = 50;     // 幅 (X)
D = 40;     // 水平フランジ 奥行 (+Y)
H = 40;     // 垂直フランジ 高さ (+Z)
T = 3;      // 板厚

HOLE_D = 4.5;   // 貫通穴 Φ4.5 (M4 バカ穴)
CS_D   = 8;     // 皿座面 Φ8
CS_H   = 2;     // 皿座 深さ 2
EDGE   = 10;    // 面の縁から穴中心までの距離

EPS = 0.01;

X_OFF = W/2 - EDGE;   // ±15 : 左右対称配置
Y_POS = D/2;          //  20 : 水平面の中心線
Z_POS = H/2;          //  20 : 垂直面の中心線

/* ---------------- 皿穴モジュール ----------------
   材料は z = 0 → t に存在し、皿座は z = 0 側(-Z 方向)に開口   */
module csk_hole(t = T) {
    ext   = 1;                                  // 座面を面外へ延長(差集合用)
    slope = (CS_D - HOLE_D) / (2 * CS_H);       // 皿のテーパ

    // 貫通穴
    translate([0, 0, -EPS])
        cylinder(h = t + 2*EPS, d = HOLE_D);

    // 皿座(円錐)
    translate([0, 0, -ext])
        cylinder(h = ext + CS_H, d1 = CS_D + 2*slope*ext, d2 = HOLE_D);
}

/* ---------------- 本体 ---------------- */
module bracket_body() {
    // 水平フランジ : x = -W/2..W/2 , y = -T..D , z = -T..0
    translate([-W/2, -T, -T]) cube([W, D + T, T]);

    // 垂直フランジ : x = -W/2..W/2 , y = -T..0 , z = -T..H
    translate([-W/2, -T, -T]) cube([W, T, H + T]);
}

module l_bracket() {
    difference() {
        bracket_body();

        // 水平面の2穴(皿座は下面 z = -T = 外側 に向く)
        for (x = [-X_OFF, X_OFF])
            translate([x, Y_POS, -T])
                csk_hole(T);

        // 垂直面の2穴(皿座は背面 y = -T = 外側 に向く)
        for (x = [-X_OFF, X_OFF])
            translate([x, -T, Z_POS])
                rotate([-90, 0, 0])
                    csk_hole(T);
    }
}

l_bracket();