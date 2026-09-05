$fn = 64;

// パラメータ
width = 50;       // 幅 (X)
flange_h = 40;    // 水平面の奥行き (Y)
flange_v = 40;    // 垂直面の高さ (Z)
thickness = 3;    // 板厚

hole_d = 4.5;     // 貫通穴径
cs_d = 8.0;       // 皿穴最大径
cs_depth = 2.0;   // 皿穴深さ
edge_margin = 10; // 端からの穴位置

module countersunk_hole() {
    // 外側(z=0)から内側(+z方向)に向けて貫通する皿穴
    translate([0, 0, -0.1]) {
        cylinder(d = hole_d, h = thickness + 0.2);
        cylinder(d1 = cs_d, d2 = hole_d, h = cs_depth + 0.1);
    }
}

difference() {
    // L字金具の本体
    union() {
        // 水平面
        translate([0, 0, -thickness])
            cube([width, flange_h, thickness]);
        // 垂直面
        translate([0, -thickness, 0])
            cube([width, thickness, flange_v]);
        // コーナー接合部
        translate([0, -thickness, -thickness])
            cube([width, thickness, thickness]);
    }

    // 水平面の皿穴 (外側 Z=-3 から上向き)
    for (x = [edge_margin, width - edge_margin]) {
        translate([x, flange_h / 2, -thickness])
            countersunk_hole();
    }

    // 垂直面の皿穴 (外側 Y=-3 から奥向き)
    for (x = [edge_margin, width - edge_margin]) {
        translate([x, -thickness, flange_v / 2])
            rotate([-90, 0, 0])
                countersunk_hole();
    }
}