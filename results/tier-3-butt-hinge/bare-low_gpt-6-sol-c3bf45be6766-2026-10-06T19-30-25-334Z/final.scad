$fn = 96;

// 寸法（mm）
leaf_length = 30;
leaf_width = 25;
leaf_thickness = 2;

pin_diameter = 4;
pin_length = 32;

knuckle_length = 6;
knuckle_outer_diameter = 8;
knuckle_inner_diameter = 4.6;

// 板の内側の縁を筒部に少し重ねて接合する
leaf_inner_x = 3.5;
hole_edge_offset = 5;
hole_pitch = 8;

module y_cylinder(d, h) {
    rotate([-90, 0, 0])
        cylinder(d = d, h = h);
}

module hinge_leaf(side, knuckle_starts) {
    outer_x = leaf_inner_x + leaf_width;
    hole_x = side * (outer_x - hole_edge_offset);

    difference() {
        union() {
            // 板：両板の表裏面をそれぞれ同一平面に配置
            translate([
                side < 0 ? -outer_x : leaf_inner_x,
                0,
                -leaf_thickness / 2
            ])
                cube([leaf_width, leaf_length, leaf_thickness]);

            // 交互にかみ合う筒部
            for (y0 = knuckle_starts)
                translate([0, y0, 0])
                    y_cylinder(knuckle_outer_diameter, knuckle_length);
        }

        // 筒部のピン穴
        for (y0 = knuckle_starts)
            translate([0, y0 - 0.01, 0])
                y_cylinder(knuckle_inner_diameter,
                           knuckle_length + 0.02);

        // M3 貫通穴と、上面から深さ 1 mm の皿穴
        for (y = [7, 7 + hole_pitch, 7 + 2 * hole_pitch]) {
            translate([hole_x, y, -leaf_thickness / 2 - 0.01])
                cylinder(d = 3.2, h = leaf_thickness + 0.02);

            translate([hole_x, y, 0])
                cylinder(d1 = 3.2, d2 = 6, h = 1);
        }
    }
}

// 左板：外側 2 個と中央 1 個
hinge_leaf(-1, [0, 12, 24]);

// 右板：中間 2 個
hinge_leaf(1, [6, 18]);

// ピン軸：筒部の両端から 1 mm ずつ突出
translate([0, -1, 0])
    y_cylinder(pin_diameter, pin_length);