$fn = 96;

leaf_length = 30;
leaf_width = 25;
leaf_thickness = 2;

pin_diameter = 4;
pin_length = 32;
knuckle_outer_diameter = 8;
knuckle_bore_diameter = 4.6;
knuckle_length = 6;

// 板の内側端を軸から3.5 mmに置き、担当する筒部と接合する。
inner_edge = 3.5;

module knuckle(index) {
    translate([0, index * knuckle_length, 0])
        rotate([-90, 0, 0])
            difference() {
                cylinder(h = knuckle_length, d = knuckle_outer_diameter);
                translate([0, 0, -0.05])
                    cylinder(h = knuckle_length + 0.1,
                             d = knuckle_bore_diameter);
            }
}

module leaf(is_left) {
    x_min = is_left ? -inner_edge - leaf_width : inner_edge;
    hole_x = (is_left ? -1 : 1) * (inner_edge + leaf_width - 6);

    difference() {
        union() {
            translate([x_min, 0, -leaf_thickness / 2])
                cube([leaf_width, leaf_length, leaf_thickness]);

            for (i = [0:4])
                if ((i % 2 == 0) == is_left)
                    knuckle(i);
        }

        // 相手側の筒部が入る区間だけ、板の内側端を逃がす。
        for (i = [0:4])
            if ((i % 2 == 0) != is_left)
                translate([0, i * knuckle_length, 0])
                    rotate([-90, 0, 0])
                        cylinder(h = knuckle_length,
                                 d = knuckle_outer_diameter + 0.2);

        // 上面から深さ1 mmの皿穴と、直径3.2 mmの貫通穴。
        for (hole_y = [7:8:23]) {
            translate([hole_x, hole_y, -1.1])
                cylinder(h = 2.2, d = 3.2);
            translate([hole_x, hole_y, 0])
                cylinder(h = 1, d1 = 3.2, d2 = 6);
        }
    }
}

color([0.72, 0.74, 0.77]) leaf(true);
color([0.82, 0.83, 0.85]) leaf(false);

color([0.40, 0.43, 0.47])
    translate([0, -1, 0])
        rotate([-90, 0, 0])
            cylinder(h = pin_length, d = pin_diameter);