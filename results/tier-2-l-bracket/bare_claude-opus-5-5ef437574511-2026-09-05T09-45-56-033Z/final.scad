// =========================================
//  L-Bracket (L字金具) with countersunk holes
//  内側コーナー = 原点
//  水平面: +Y 方向 / 垂直面: +Z 方向
// =========================================

$fn = 64;

// ---- 基本寸法 ----
width  = 50;   // 幅 (X)
depth  = 40;   // 水平フランジの奥行き (Y)
height = 40;   // 垂直フランジの高さ (Z)
t      = 3;    // 板厚

// ---- 皿穴寸法 (M4) ----
hole_d   = 4.5;  // 貫通穴径
cs_d     = 8.0;  // 皿座面径
cs_depth = 2.0;  // 皿座面深さ

// ---- 穴位置 ----
edge_off = 10;                 // 縁からの内側寄せ量
x_off    = width/2 - edge_off; // = 15 (左右対称)
hy       = depth/2;            // 水平面 中心線 (Y=20)
hz       = height/2;           // 垂直面 中心線 (Z=20)

eps = 0.01;

// 皿穴: 板の外表面が z=0、材料は -Z 方向、皿座面は +Z 側に開く
module csk_hole(thk = t) {
    // 貫通穴
    translate([0, 0, -thk - 1])
        cylinder(h = thk + 2, d = hole_d);
    // 皿(テーパ)部
    translate([0, 0, -cs_depth])
        cylinder(h = cs_depth, d1 = hole_d, d2 = cs_d);
    // 座面上の逃げ
    cylinder(h = 1, d = cs_d);
}

module l_bracket() {
    difference() {
        // ---- 本体 ----
        union() {
            // 水平フランジ (+Y 方向, 上面 z=0)
            translate([-width/2, 0, -t])
                cube([width, depth, t]);
            // 垂直フランジ (+Z 方向, 前面 y=0) ※コーナー部を含む
            translate([-width/2, -t, -t])
                cube([width, t, height + t]);
        }

        // ---- 水平面の皿穴 (座面は下側 = 外側) ----
        for (sx = [-1, 1])
            translate([sx * x_off, hy, -t])
                rotate([180, 0, 0])
                    csk_hole(t);

        // ---- 垂直面の皿穴 (座面は -Y 側 = 外側) ----
        for (sx = [-1, 1])
            translate([sx * x_off, -t, hz])
                rotate([90, 0, 0])
                    csk_hole(t);
    }
}

l_bracket();