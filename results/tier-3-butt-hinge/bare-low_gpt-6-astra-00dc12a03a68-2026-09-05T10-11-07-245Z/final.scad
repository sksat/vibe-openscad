// 単位: mm。Y=0～30 が筒部、Y=-1～31 がピン。
// 左右の板は Z=-4～-2 に配置し、180°開いた状態とする。
$fn = 96;

leaf_length = 30;
leaf_width  = 25;
leaf_thick  = 2;

pin_d       = 4;
pin_length  = 32;
knuckle_od  = 8;
bore_d      = 4.6;

segment     = leaf_length / 5;
leaf_inner  = knuckle_od / 2;
leaf_bottom = -knuckle_od / 2;
leaf_top    = leaf_bottom + leaf_thick;

screw_d     = 3.2;
sink_d      = 6;
sink_depth  = 1;
hole_pitch  = 8;
hole_x      = leaf_inner + leaf_width - 6;

eps = 0.01;

// ローカルZ軸の円柱を、+Y方向へ向ける。
module cylinder_y(d, h) {
    rotate([-90, 0, 0])
        cylinder(d = d, h = h);
}

// 右側を原型とし、左側はX方向に鏡映する。
module place_side(side) {
    if (side < 0)
        mirror([1, 0, 0]) children();
    else
        children();
}

module screw_hole(x, y) {
    translate([x, y, leaf_bottom - eps])
        cylinder(d = screw_d, h = leaf_thick + 2 * eps);

    // +Z側表面から深さ1mmの皿穴。
    translate([x, y, leaf_top - sink_depth])
        cylinder(d1 = screw_d, d2 = sink_d, h = sink_depth);

    translate([x, y, leaf_top - eps])
        cylinder(d = sink_d, h = 2 * eps);
}

module leaf(side, knuckle_indices) {
    place_side(side)
        difference() {
            union() {
                // 板本体: 幅25 × 長さ30 × 厚さ2。
                translate([leaf_inner, 0, leaf_bottom])
                    cube([leaf_width, leaf_length, leaf_thick]);

                for (i = knuckle_indices) {
                    translate([0, i * segment, 0])
                        cylinder_y(d = knuckle_od, h = segment);

                    // 各筒部のみに接続する一体の根元。
                    // 相手側の筒部がある区間には張り出さない。
                    translate([0, i * segment, leaf_bottom])
                        cube([
                            leaf_inner + 0.5,
                            segment,
                            leaf_thick
                        ]);
                }
            }

            // 根元も含めて穴を抜き、ピンとの隙間を確保。
            translate([0, -eps, 0])
                cylinder_y(
                    d = bore_d,
                    h = leaf_length + 2 * eps
                );

            for (y = [
                leaf_length / 2 - hole_pitch,
                leaf_length / 2,
                leaf_length / 2 + hole_pitch
            ])
                screw_hole(hole_x, y);
        }
}

module pin() {
    translate([0, -(pin_length - leaf_length) / 2, 0])
        cylinder_y(d = pin_d, h = pin_length);
}

// 完成組立: 独立した左板・右板・ピンの3パーツ。
// 筒部は各6mmで交互に配置し、端面同士は接触する。
color([0.66, 0.69, 0.73])
    leaf(-1, [0, 2, 4]);

color([0.73, 0.76, 0.80])
    leaf(1, [1, 3]);

color([0.40, 0.43, 0.48])
    pin();