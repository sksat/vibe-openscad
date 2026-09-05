$fn = 96;

// 寸法（mm）
width             = 50;
horizontal_depth  = 40;
vertical_height   = 40;
thickness         = 3;

edge_offset       = 10;
hole_diameter     = 4.5;
sink_diameter     = 8;
sink_depth        = 2;

eps = 0.01;

// 外側表面をローカル z=0 とし、+Z 方向へ穴を掘る。
module countersunk_hole() {
    // 貫通穴
    translate([0, 0, -eps])
        cylinder(
            h = thickness + 2 * eps,
            d = hole_diameter
        );

    // 円錐状の皿座面。
    // 表面で正確に Φ8、深さ 2 mm で Φ4.5 となる。
    translate([0, 0, -eps])
        cylinder(
            h  = sink_depth + eps,
            d1 = sink_diameter
                 + (sink_diameter - hole_diameter)
                   * eps / sink_depth,
            d2 = hole_diameter
        );
}

difference() {
    union() {
        // 水平フランジ：内側面 z=0、+Y 方向。
        translate([-width / 2, 0, -thickness])
            cube([width, horizontal_depth, thickness]);

        // 垂直フランジ：内側面 y=0、+Z 方向。
        translate([-width / 2, -thickness, 0])
            cube([width, thickness, vertical_height]);

        // 内側コーナーの外側を埋め、両フランジを一体化。
        translate([-width / 2, -thickness, -thickness])
            cube([width, thickness, thickness]);
    }

    for (x = [-width / 2 + edge_offset,
               width / 2 - edge_offset]) {
        // 水平面：中心線 y=20、皿座面は外側（-Z）。
        translate([x, horizontal_depth / 2, -thickness])
            countersunk_hole();

        // 垂直面：中心線 z=20、皿座面は外側（-Y）。
        translate([x, -thickness, vertical_height / 2])
            rotate([-90, 0, 0])
                countersunk_hole();
    }
}