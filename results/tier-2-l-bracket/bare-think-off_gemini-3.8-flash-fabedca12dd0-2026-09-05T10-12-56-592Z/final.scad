$fn = 64;

width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_d = 4.5;
cs_d = 8.0;
cs_depth = 2.0;

module countersunk_hole() {
    // 貫通穴
    cylinder(d = hole_d, h = thickness + 2, center = true);
    // 皿座面 (円錐台)
    translate([0, 0, -thickness / 2 - 0.01])
        cylinder(d1 = cs_d, d2 = hole_d, h = cs_depth + 0.01);
}

difference() {
    // L字金具のベース形状
    union() {
        // 水平面
        translate([-width / 2, 0, -thickness])
            cube([width, depth, thickness]);
        // 垂直面
        translate([-width / 2, -thickness, 0])
            cube([width, thickness, height]);
    }

    // 水平面の皿穴 (外側: -Z 方向からボルト挿入)
    for (x = [-width / 2 + 10, width / 2 - 10]) {
        translate([x, depth / 2, -thickness / 2])
            countersunk_hole();
    }

    // 垂直面の皿穴 (外側: -Y 方向からボルト挿入)
    for (x = [-width / 2 + 10, width / 2 - 10]) {
        translate([x, -thickness / 2, height / 2])
            rotate([-90, 0, 0])
                countersunk_hole();
    }
}