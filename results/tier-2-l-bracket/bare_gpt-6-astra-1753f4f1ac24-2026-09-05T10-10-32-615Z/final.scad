// 単位: mm
$fn = 96;

width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_d = 4.5;
countersink_d = 8;
countersink_depth = 2;
edge_offset = 10;

eps = 0.01;

// 局所座標の Z=0 が外側表面、+Z が板の内側。
module countersunk_hole() {
    translate([0, 0, -eps])
        cylinder(
            h = thickness + 2 * eps,
            d = hole_d
        );

    translate([0, 0, -eps])
        cylinder(
            h = countersink_depth + eps,
            d1 = countersink_d
                 + (countersink_d - hole_d)
                   * eps / countersink_depth,
            d2 = hole_d
        );
}

difference() {
    union() {
        // 水平フランジ: 内側表面 Z=0、+Y 方向。
        translate([-width / 2, 0, -thickness])
            cube([width, depth, thickness]);

        // 垂直フランジ: 内側表面 Y=0、+Z 方向。
        translate([-width / 2, -thickness, 0])
            cube([width, thickness, height]);

        // 内側コーナーを原点とし、外側の角を埋めて一体化。
        translate([-width / 2, -thickness, -thickness])
            cube([width, thickness, thickness]);
    }

    for (x = [
        -width / 2 + edge_offset,
         width / 2 - edge_offset
    ]) {
        // 水平面: 皿座面は下面（-Z 側）。
        translate([x, depth / 2, -thickness])
            countersunk_hole();

        // 垂直面: 皿座面は背面（-Y 側）。
        translate([x, -thickness, height / 2])
            rotate([-90, 0, 0])
                countersunk_hole();
    }
}