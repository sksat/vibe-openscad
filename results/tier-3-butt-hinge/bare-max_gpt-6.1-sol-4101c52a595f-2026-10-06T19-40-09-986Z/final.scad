// 単位: mm
$fn = 128;

leaf_length    = 30;
leaf_width     = 25;
leaf_thickness = 2;

pin_diameter = 4;
pin_length   = 32;

knuckle_outer_diameter = 8;
radial_clearance       = 0.3;
knuckle_inner_diameter = pin_diameter + 2 * radial_clearance; // 4.6
knuckle_length         = leaf_length / 5;                    // 6

through_hole_diameter = 3.2;
countersink_diameter  = 6;
countersink_depth     = 1;
hole_pitch           = 8;
hole_edge_margin     = 5;

opening_angle = 180;
eps = 0.02;

// 両板の表面を Z=0、裏面を Z=-2 に配置。
// 他方の筒部に板の内側縁が接触しないように離す。
leaf_inner_x = knuckle_outer_diameter / 2 + 0.2;
leaf_bottom_z = -leaf_thickness;
neck_inner_x = knuckle_inner_diameter / 2;

module cylinder_y(d, h) {
    rotate([-90, 0, 0])
        cylinder(d = d, h = h, center = false);
}

module countersunk_hole(x, y) {
    // 直径3.2 mmの貫通穴
    translate([x, y, leaf_bottom_z - eps])
        cylinder(
            d = through_hole_diameter,
            h = leaf_thickness + 2 * eps
        );

    // Z=0で直径6 mm、Z=-1で直径3.2 mmのテーパ。
    // 表面より上まで延長し、差分演算の同一面を避ける。
    translate([x, y, -countersink_depth])
        cylinder(
            h  = countersink_depth + eps,
            d1 = through_hole_diameter,
            d2 = countersink_diameter
                 + (countersink_diameter - through_hole_diameter)
                   * eps / countersink_depth
        );
}

// +X側を基準に作る、板・接続部・筒部からなる一体の部品。
module leaf(knuckle_indices) {
    difference() {
        union() {
            translate([leaf_inner_x, 0, leaf_bottom_z])
                cube([leaf_width, leaf_length, leaf_thickness]);

            for (i = knuckle_indices) {
                // 筒部: Y方向に正確に6 mmずつ配置
                translate([0, i * knuckle_length, 0])
                    cylinder_y(
                        d = knuckle_outer_diameter,
                        h = knuckle_length
                    );

                // 自分の筒部だけを板に接続するネック
                translate([
                    neck_inner_x,
                    i * knuckle_length,
                    leaf_bottom_z
                ])
                    cube([
                        leaf_inner_x - neck_inner_x + eps,
                        knuckle_length,
                        leaf_thickness
                    ]);
            }
        }

        // 接続部も含めて軸穴を確保
        translate([0, -eps, 0])
            cylinder_y(
                d = knuckle_inner_diameter,
                h = leaf_length + 2 * eps
            );

        for (i = [-1 : 1])
            countersunk_hole(
                x = leaf_inner_x + leaf_width - hole_edge_margin,
                y = leaf_length / 2 + i * hole_pitch
            );
    }
}

module left_leaf() {
    mirror([1, 0, 0])
        leaf([0, 2, 4]);
}

module right_leaf() {
    leaf([1, 3]);
}

module hinge_pin() {
    // 筒部のY範囲0～30に対し、ピンは-1～31。
    translate([0, -(pin_length - leaf_length) / 2, 0])
        cylinder_y(d = pin_diameter, h = pin_length);
}

// 3部品を共有するY軸上で組み立てる。
color([0.65, 0.68, 0.72])
    left_leaf();

color([0.75, 0.77, 0.80])
    rotate([0, opening_angle - 180, 0])
        right_leaf();

color([0.45, 0.48, 0.52])
    hinge_pin();