$fn = 96;

// 寸法 (mm)
leaf_length = 30;
leaf_width = 25;
plate_thickness = 2;

knuckle_length = 6;
knuckle_od = 8;
knuckle_id = 4.6;

pin_diameter = 4;
pin_length = 32;

screw_diameter = 3.2;
countersink_diameter = 6;
countersink_depth = 1;
epsilon = 0.01;

// 板の根元を knuckle にわずかに重ねて一体化
leaf_root_x = knuckle_od / 2 - 0.25;
leaf_center_x = leaf_root_x + leaf_width / 2;

module knuckle(y_center) {
    translate([0, y_center, 0])
        rotate([-90, 0, 0])
            difference() {
                cylinder(h = knuckle_length, d = knuckle_od, center = true);
                cylinder(h = knuckle_length + 2 * epsilon,
                         d = knuckle_id, center = true);
            }
}

module leaf(side, knuckle_centers) {
    hole_x = side * leaf_center_x;
    countersink_top_d =
        countersink_diameter
        + (countersink_diameter - screw_diameter)
          * epsilon / countersink_depth;

    difference() {
        union() {
            translate([side * leaf_center_x, 0, 0])
                cube([leaf_width, leaf_length, plate_thickness], center = true);

            for (yc = knuckle_centers)
                knuckle(yc);
        }

        for (hole_y = [-8, 0, 8]) {
            translate([hole_x, hole_y, -plate_thickness / 2 - epsilon])
                cylinder(h = plate_thickness + 2 * epsilon,
                         d = screw_diameter);

            translate([hole_x, hole_y,
                       plate_thickness / 2 - countersink_depth])
                cylinder(h = countersink_depth + epsilon,
                         d1 = screw_diameter,
                         d2 = countersink_top_d);
        }
    }
}

// 左板: 外側2個と中央1個
color([0.72, 0.74, 0.77])
    leaf(-1, [-12, 0, 12]);

// 右板: 中間2個
color([0.72, 0.74, 0.77])
    leaf(1, [-6, 6]);

// ピン軸: Y方向、両端が knuckle から各1 mm突出
color([0.48, 0.50, 0.53])
    rotate([-90, 0, 0])
        cylinder(h = pin_length, d = pin_diameter, center = true);