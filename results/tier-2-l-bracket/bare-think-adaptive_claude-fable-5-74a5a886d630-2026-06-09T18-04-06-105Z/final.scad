// L字金具 (L-bracket)
// 内側コーナーが原点。水平フランジは +Y、垂直フランジは +Z 方向。

$fn = 64;

// ---- パラメータ ----
width     = 50;   // 幅 (X方向)
depth     = 40;   // 水平面の奥行き (Y方向)
height    = 40;   // 垂直面の高さ (Z方向)
thickness = 3;    // 板厚

hole_d    = 4.5;  // M4 貫通穴径
cs_d      = 8;    // 皿座面径
cs_depth  = 2;    // 皿座面深さ
edge_off  = 10;   // 縁からのオフセット
eps       = 0.1;  // ブーリアン用の余裕

hole_x = width/2 - edge_off;  // 穴のX位置 (±15mm)

// 皿穴モジュール: 外側面が z=0、板は +Z 方向に thickness
module csk_hole() {
    // 貫通穴
    translate([0, 0, -eps])
        cylinder(d = hole_d, h = thickness + 2*eps);
    // 皿座面(円錐)
    cylinder(d1 = cs_d, d2 = hole_d, h = cs_depth);
    // 外側面手前の取り残し防止
    translate([0, 0, -eps])
        cylinder(d = cs_d, h = eps + 0.01);
}

difference() {
    // ---- 本体 ----
    union() {
        // 水平フランジ (上面が z=0)
        translate([-width/2, 0, -thickness])
            cube([width, depth, thickness]);
        // 垂直フランジ (内側面が y=0)
        translate([-width/2, -thickness, 0])
            cube([width, thickness, height]);
        // コーナーの埋め
        translate([-width/2, -thickness, -thickness])
            cube([width, thickness, thickness]);
    }

    // ---- 水平フランジの皿穴 (皿座面は下側 = 外側) ----
    for (x = [-hole_x, hole_x])
        translate([x, depth/2, -thickness])
            csk_hole();

    // ---- 垂直フランジの皿穴 (皿座面は背面側 = 外側) ----
    for (x = [-hole_x, hole_x])
        translate([x, -thickness, height/2])
            rotate([-90, 0, 0])
                csk_hole();
}