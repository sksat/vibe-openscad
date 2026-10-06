$fn = 96;

// 180°で展開。値を変えると右板がピン軸の周りに回転する。
opening_angle = 180;

leaf_length = 30;
leaf_width = 25;
leaf_thickness = 2;
leaf_inner_x = 3;
leaf_bottom_z = -3;

knuckle_length = 6;
knuckle_outer_d = 8;
knuckle_inner_d = 4.6;

pin_d = 4;
pin_length = 32;

// 相手側の筒部に板が干渉しないよう、該当区間の板端を逃がす。
relief_x = 4.15;

function owns_knuckle(i, is_left) =
    is_left ? (i % 2 == 0) : (i % 2 == 1);

module y_cylinder(diameter, length, y_start) {
    translate([0, y_start, 0])
        rotate([-90, 0, 0])
            cylinder(d = diameter, h = length);
}

module knuckle(i) {
    difference() {
        y_cylinder(knuckle_outer_d, knuckle_length,
                   i * knuckle_length);
        y_cylinder(knuckle_inner_d, knuckle_length + 0.2,
                   i * knuckle_length - 0.1);
    }
}

module positive_x_leaf(is_left) {
    difference() {
        union() {
            difference() {
                translate([leaf_inner_x, 0, leaf_bottom_z])
                    cube([leaf_width, leaf_length, leaf_thickness]);

                for (i = [0:4])
                    if (!owns_knuckle(i, is_left))
                        translate([leaf_inner_x - 0.1,
                                   i * knuckle_length,
                                   leaf_bottom_z - 0.1])
                            cube([relief_x - leaf_inner_x + 0.1,
                                  knuckle_length,
                                  leaf_thickness + 0.2]);
            }

            for (i = [0:4])
                if (owns_knuckle(i, is_left))
                    knuckle(i);
        }

        // 表面（+Z側）から深さ1 mmのM3皿穴を3個。
        for (i = [0:2]) {
            translate([leaf_inner_x + leaf_width - 6,
                       7 + i * 8,
                       leaf_bottom_z - 0.1])
                cylinder(d = 3.2, h = leaf_thickness + 0.2);

            translate([leaf_inner_x + leaf_width - 6,
                       7 + i * 8,
                       leaf_bottom_z + leaf_thickness - 1])
                cylinder(d1 = 3.2, d2 = 6, h = 1);
        }
    }
}

module left_leaf() {
    mirror([1, 0, 0])
        positive_x_leaf(true);
}

module right_leaf() {
    positive_x_leaf(false);
}

module pin() {
    y_cylinder(pin_d, pin_length, -1);
}

color([0.76, 0.78, 0.80])
    left_leaf();

color([0.66, 0.69, 0.72])
    rotate([0, opening_angle - 180, 0])
        right_leaf();

color([0.88, 0.89, 0.90])
    pin();