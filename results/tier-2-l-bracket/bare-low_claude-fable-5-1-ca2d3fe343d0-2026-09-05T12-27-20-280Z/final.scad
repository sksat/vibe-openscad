// L-bracket with countersunk holes (M4)
// Inner corner at origin. Horizontal flange extends +Y, vertical flange extends +Z.

$fn = 64;

// ---- Parameters ----
width       = 50;   // X 方向の幅 (両フランジ共通)
h_depth     = 40;   // 水平面の奥行き (Y)
v_height    = 40;   // 垂直面の高さ (Z)
thickness   = 3;    // 板厚

hole_d      = 4.5;  // M4 貫通穴
cs_d        = 8;    // 皿座面径
cs_depth    = 2;    // 皿座面深さ
edge_offset = 10;   // 面の縁から穴中心までの距離
hole_gap    = 20;   // 2 穴の中心間隔 (左右対称: ±10mm)

eps = 0.01;

// ---- Countersunk hole module ----
// Z軸方向に伸びる穴。皿座面は +Z 側 (z=0 が皿の開口面)。
module countersunk_hole(len) {
    // 貫通穴
    translate([0, 0, -len - eps])
        cylinder(d = hole_d, h = len + 2 * eps);
    // 皿座面 (円錐: 開口 cs_d → 底 hole_d)
    translate([0, 0, -cs_depth])
        cylinder(d1 = hole_d, d2 = cs_d, h = cs_depth + eps);
    // 開口面より外側の逃げ
    translate([0, 0, -eps])
        cylinder(d = cs_d, h = 1);
}

// ---- Bracket ----
module l_bracket() {
    difference() {
        union() {
            // 水平面: 底面 z=-thickness ~ 0, Y は 0 ~ h_depth
            translate([-width / 2, -thickness, -thickness])
                cube([width, h_depth + thickness, thickness]);
            // 垂直面: Y は -thickness ~ 0, Z は 0 ~ v_height
            translate([-width / 2, -thickness, -thickness])
                cube([width, thickness, v_height + thickness]);
        }

        // 水平面の穴 (皿は下側 = 外側に向ける)
        for (x = [-hole_gap / 2, hole_gap / 2])
            translate([x, h_depth - edge_offset, -thickness])
                mirror([0, 0, 1])
                    countersunk_hole(thickness);

        // 垂直面の穴 (皿は -Y 側 = 外側に向ける)
        for (x = [-hole_gap / 2, hole_gap / 2])
            translate([x, -thickness, v_height - edge_offset])
                rotate([90, 0, 0])
                    countersunk_hole(thickness);
    }
}

l_bracket();