// 家具用バット蝶番：180° 開いた組立状態
// 軸方向：+Y、左板：X<0、右板：X>0
$fn = 96;

leaf_length    = 30;
leaf_width     = 25;
leaf_thickness = 2;

pin_diameter = 4;
pin_length   = 32;

knuckle_outer_diameter = 8;
radial_clearance       = 0.3;
knuckle_inner_diameter = pin_diameter + 2 * radial_clearance;
knuckle_length         = leaf_length / 5;

screw_hole_diameter  = 3.2;
countersink_diameter = 6;
countersink_depth    = 1;
screw_pitch          = 8;
screw_edge_distance  = 5;

outer_radius = knuckle_outer_diameter / 2;

// 両板の下面を Z=-4、上面を Z=-2 に揃える。
// 板本体は筒部の外側から伸ばし、相手側の筒部と干渉させない。
leaf_bottom = -outer_radius;
leaf_top    = leaf_bottom + leaf_thickness;

eps = 0.01;
web_overlap = 0.25;

// Z 軸向きの円柱を +Y 軸向きにする。
module cylinder_y(y_start, length, diameter) {
    translate([0, y_start, 0])
        rotate([-90, 0, 0])
            cylinder(h = length, d = diameter);
}

// 筒部と板をつなぐ部分。各板が所有する区間だけに配置する。
module connection_web(side, y_start) {
    web_inner_x = outer_radius / 2;
    web_outer_x = outer_radius + web_overlap;

    translate([
        side < 0 ? -web_outer_x : web_inner_x,
        y_start,
        leaf_bottom
    ])
        cube([
            web_outer_x - web_inner_x,
            knuckle_length,
            leaf_thickness
        ]);
}

// 上面からの皿穴：直径 6、深さ 1 のテーパと直径 3.2 の貫通穴。
module countersunk_hole(x, y) {
    translate([x, y, leaf_bottom - eps])
        cylinder(
            h = leaf_thickness + 2 * eps,
            d = screw_hole_diameter
        );

    // 上面を少し越えて切り抜き、上面位置で正確に直径 6 にする。
    translate([x, y, leaf_top - countersink_depth])
        cylinder(
            h  = countersink_depth + eps,
            d1 = screw_hole_diameter,
            d2 = countersink_diameter
               + (countersink_diameter - screw_hole_diameter)
               * eps / countersink_depth
        );
}

module hinge_leaf(side) {
    // 左：0〜6、12〜18、24〜30
    // 右：6〜12、18〜24
    knuckle_indices = side < 0 ? [0, 2, 4] : [1, 3];

    hole_x = side * (
        outer_radius + leaf_width - screw_edge_distance
    );

    difference() {
        union() {
            translate([
                side < 0
                    ? -(outer_radius + leaf_width)
                    : outer_radius,
                0,
                leaf_bottom
            ])
                cube([leaf_width, leaf_length, leaf_thickness]);

            for (i = knuckle_indices) {
                cylinder_y(
                    i * knuckle_length,
                    knuckle_length,
                    knuckle_outer_diameter
                );

                connection_web(side, i * knuckle_length);
            }
        }

        // 筒部の軸穴：直径 4.6 mm。
        cylinder_y(
            -eps,
            leaf_length + 2 * eps,
            knuckle_inner_diameter
        );

        // Y=7、15、23：縦方向ピッチ 8 mm。
        for (offset = [-1, 0, 1])
            countersunk_hole(
                hole_x,
                leaf_length / 2 + offset * screw_pitch
            );
    }
}

module left_leaf() {
    hinge_leaf(-1);
}

module right_leaf() {
    hinge_leaf(1);
}

module hinge_pin() {
    // Y=-1〜31：筒部の両端から各 1 mm 突出。
    cylinder_y(
        -(pin_length - leaf_length) / 2,
        pin_length,
        pin_diameter
    );
}

// 独立した 3 パーツを、共通の軸線上に組み立てて配置。
color([0.68, 0.70, 0.73])
    left_leaf();

color([0.75, 0.77, 0.80])
    right_leaf();

color([0.40, 0.43, 0.47])
    hinge_pin();