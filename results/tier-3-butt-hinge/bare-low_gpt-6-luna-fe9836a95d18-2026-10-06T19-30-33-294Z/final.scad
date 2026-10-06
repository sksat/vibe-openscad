$fn = 96;

leaf_length = 30;
leaf_width  = 25;
leaf_thick  = 2;

pin_diameter = 4;
pin_length   = 32;

knuckle_outer_d = 8;
knuckle_inner_d = 4.6;
knuckle_length  = 6;

plate_inner_x = knuckle_outer_d / 2 - 0.5;

module y_cylinder(d, h) {
    rotate([-90, 0, 0])
        cylinder(d = d, h = h);
}

module knuckle(y_start) {
    difference() {
        y_cylinder(knuckle_outer_d, knuckle_length);
        translate([0, 0, -0.01])
            y_cylinder(knuckle_inner_d, knuckle_length + 0.02);
    }
}

module screw_cuts(x, y) {
    // Through hole
    translate([x, y, -leaf_thick / 2 - 0.1])
        cylinder(d = 3.2, h = leaf_thick + 0.2);

    // Countersink: 6 mm diameter at the top surface, 1 mm deep
    translate([x, y, leaf_thick / 2 - 1])
        cylinder(h = 1, d1 = 3.2, d2 = 6);
}

module leaf(side, knuckle_positions) {
    far_x = side * (plate_inner_x + leaf_width);
    inner_x = side * plate_inner_x;
    plate_center_x = (far_x + inner_x) / 2;
    screw_x = side * (abs(far_x) - 4);

    difference() {
        union() {
            translate([plate_center_x, leaf_length / 2, 0])
                cube([leaf_width, leaf_length, leaf_thick], center = true);

            for (y_start = knuckle_positions)
                knuckle(y_start);
        }

        for (y = [7, 15, 23])
            screw_cuts(screw_x, y);
    }
}

color("silver") {
    leaf(-1, [0, 12, 24]);
    leaf( 1, [6, 18]);
}

color("silver")
    translate([0, -1, 0])
        y_cylinder(pin_diameter, pin_length);