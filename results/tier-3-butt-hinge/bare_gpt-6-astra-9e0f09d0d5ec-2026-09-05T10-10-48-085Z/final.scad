$fn = 96;

// 寸法（mm）
leaf_length = 30;
leaf_width = 25;
leaf_thickness = 2;

pin_diameter = 4;
pin_length = 32;

knuckle_od = 8;
pin_radial_clearance = 0.3;
knuckle_id = pin_diameter + 2 * pin_radial_clearance;
knuckle_count = 5;
knuckle_length = leaf_length / knuckle_count;

screw_diameter = 3.2;
countersink_diameter = 6;
countersink_depth = 1;
hole_pitch = 8;
hole_edge_distance = 5;

eps = 0.01;

// 相手側の筒部と板が干渉しないための隙間
leaf_barrel_clearance = 0.2;
leaf_root = knuckle_od / 2 + leaf_barrel_clearance;
connector_overlap = 0.5;

// 両板の上面は Z=0、下面は Z=-2。
// 軸中心線は X=0, Z=0、筒部は Y=0～30。

module cylinder_y(d, h) {
    rotate([-90, 0, 0])
        cylinder(d = d, h = h);
}

module screw_hole(x, y) {
    // 直径3.2mmの貫通穴
    translate([x, y, -leaf_thickness - eps])
        cylinder(
            d = screw_diameter,
            h = leaf_thickness + 2 * eps
        );

    // 上面側：直径6mm、深さ1mmのテーパ
    translate([x, y, -countersink_depth])
        cylinder(
            d1 = screw_diameter,
            d2 = countersink_diameter,
            h = countersink_depth
        );

    // 上面のブーリアン演算を安定させる延長
    translate([x, y, 0])
        cylinder(d = countersink_diameter, h = eps);
}

// +X側を基準にした板と筒部の一体部品
module leaf_with_knuckles(segment_indices) {
    difference() {
        union() {
            // 25 × 30 × 2 mm の板
            translate([leaf_root, 0, -leaf_thickness])
                cube([leaf_width, leaf_length, leaf_thickness]);

            for (i = segment_indices) {
                // 各筒部：外径8mm、長さ6mm
                translate([0, i * knuckle_length, 0])
                    cylinder_y(
                        d = knuckle_od,
                        h = knuckle_length
                    );

                // 筒部と板を体積的に接続する根元
                translate([
                    0,
                    i * knuckle_length,
                    -leaf_thickness
                ])
                    cube([
                        leaf_root + connector_overlap,
                        knuckle_length,
                        leaf_thickness
                    ]);
            }
        }

        // 接続部分も含めて直径4.6mmの軸穴を開ける
        translate([0, -eps, 0])
            cylinder_y(
                d = knuckle_id,
                h = leaf_length + 2 * eps
            );

        // 遠端側に3穴：Y=7,15,23（8mmピッチ）
        for (j = [-1, 0, 1])
            screw_hole(
                x = leaf_root + leaf_width - hole_edge_distance,
                y = leaf_length / 2 + j * hole_pitch
            );
    }
}

module left_leaf() {
    mirror([1, 0, 0])
        leaf_with_knuckles([0, 2, 4]);
}

module right_leaf() {
    leaf_with_knuckles([1, 3]);
}

module hinge_pin() {
    // Y=-1～31：筒部の両端から1mmずつ突出
    translate([0, -(pin_length - leaf_length) / 2, 0])
        cylinder_y(d = pin_diameter, h = pin_length);
}

// 完成組立：180°開いた状態の3部品
color([0.62, 0.65, 0.69])
    left_leaf();

color([0.72, 0.75, 0.79])
    right_leaf();

color([0.38, 0.40, 0.43])
    hinge_pin();