// 単位: mm
// ピン中心線: Y軸、蝶番は180°開いた状態
$fn = 96;

leaf_length = 30;
leaf_width = 25;
leaf_thickness = 2;

pin_diameter = 4;
pin_length = 32;

knuckle_outer_diameter = 8;
knuckle_inner_diameter = 4.6;
knuckle_length = 6;

leaf_inner_x = knuckle_outer_diameter / 2;
leaf_bottom_z = -leaf_thickness;

screw_diameter = 3.2;
countersink_diameter = 6;
countersink_depth = 1;
screw_x = leaf_inner_x + leaf_width - 6;
screw_y_positions = [7, 15, 23];

epsilon = 0.02;

// +Y方向の円柱
module cylinder_y(d, h) {
    rotate([-90, 0, 0])
        cylinder(d = d, h = h);
}

// 筒部。各区間は正確に6mm。
// 隣接する筒部の端面は接するが、体積は重ならない。
module knuckle(index) {
    translate([0, index * knuckle_length, 0])
        difference() {
            cylinder_y(
                d = knuckle_outer_diameter,
                h = knuckle_length
            );

            translate([0, -epsilon, 0])
                cylinder_y(
                    d = knuckle_inner_diameter,
                    h = knuckle_length + 2 * epsilon
                );
        }
}

// 上面Z=0から加工する皿穴
module countersunk_hole(x, y) {
    translate([x, y, leaf_bottom_z - epsilon])
        cylinder(
            d = screw_diameter,
            h = leaf_thickness + 2 * epsilon
        );

    translate([x, y, -countersink_depth])
        cylinder(
            d1 = screw_diameter,
            d2 = countersink_diameter,
            h = countersink_depth
        );

    translate([x, y, 0])
        cylinder(
            d = countersink_diameter,
            h = epsilon
        );
}

// +X側の板を基準として作る。
// 板本体を筒の外径より外側に置き、
// 自分の筒部の区間だけ接続タブを設けて相手側との干渉を避ける。
module leaf_positive_x(knuckle_indices) {
    difference() {
        union() {
            translate([leaf_inner_x, 0, leaf_bottom_z])
                cube([
                    leaf_width,
                    leaf_length,
                    leaf_thickness
                ]);

            for (index = knuckle_indices) {
                knuckle(index);

                translate([
                    2.5,
                    index * knuckle_length,
                    leaf_bottom_z
                ])
                    cube([
                        leaf_inner_x - 2.5 + 0.2,
                        knuckle_length,
                        leaf_thickness
                    ]);
            }
        }

        for (y = screw_y_positions)
            countersunk_hole(screw_x, y);
    }
}

// 左板: 外側2区間と中央区間
module left_leaf() {
    mirror([1, 0, 0])
        leaf_positive_x([0, 2, 4]);
}

// 右板: 中間2区間
module right_leaf() {
    leaf_positive_x([1, 3]);
}

// 両端が筒部から各1mm突出する独立したピン
module hinge_pin() {
    translate([0, -1, 0])
        cylinder_y(
            d = pin_diameter,
            h = pin_length
        );
}

// 完成品: 独立した3パーツ
color([0.65, 0.68, 0.72])
    left_leaf();

color([0.72, 0.75, 0.79])
    right_leaf();

color([0.40, 0.43, 0.47])
    hinge_pin();