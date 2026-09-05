$fn = 96;

leaf_length    = 30;
leaf_width     = 25;
leaf_thickness = 2;

knuckle_length = 6;
knuckle_od     = 8;
knuckle_id     = 4.6;

pin_diameter   = 4;
pin_overhang   = 1;
pin_length     = leaf_length + 2 * pin_overhang;

through_d      = 3.2;
countersink_d  = 6;
countersink_depth = 1;

hole_x = leaf_width - 6;
hole_y_positions = [
    leaf_length / 2 - 8,
    leaf_length / 2,
    leaf_length / 2 + 8
];

left_knuckle_y  = [0, 12, 24];
right_knuckle_y = [6, 18];

barrel_clearance = 0.15;
eps = 0.02;

module cylinder_y(y0, len, diameter) {
    translate([0, y0, 0])
        rotate([-90, 0, 0])
            cylinder(h = len, d = diameter, center = false);
}

module countersunk_hole(x, y) {
    translate([x, y, -leaf_thickness / 2 - eps])
        cylinder(
            h = leaf_thickness + 2 * eps,
            d = through_d
        );

    cone_extra_d =
        (countersink_d - through_d) * eps / countersink_depth;

    translate([
        x,
        y,
        leaf_thickness / 2 - countersink_depth
    ])
        cylinder(
            h  = countersink_depth + eps,
            d1 = through_d,
            d2 = countersink_d + cone_extra_d
        );
}

module left_leaf() {
    difference() {
        union() {
            translate([-leaf_width, 0, -leaf_thickness / 2])
                cube([leaf_width, leaf_length, leaf_thickness]);

            for (y0 = left_knuckle_y)
                cylinder_y(y0, knuckle_length, knuckle_od);
        }

        for (y0 = left_knuckle_y)
            cylinder_y(
                y0 - eps,
                knuckle_length + 2 * eps,
                knuckle_id
            );

        for (y0 = right_knuckle_y)
            cylinder_y(
                y0,
                knuckle_length,
                knuckle_od + 2 * barrel_clearance
            );

        for (y = hole_y_positions)
            countersunk_hole(-hole_x, y);
    }
}

module right_leaf() {
    difference() {
        union() {
            translate([0, 0, -leaf_thickness / 2])
                cube([leaf_width, leaf_length, leaf_thickness]);

            for (y0 = right_knuckle_y)
                cylinder_y(y0, knuckle_length, knuckle_od);
        }

        for (y0 = right_knuckle_y)
            cylinder_y(
                y0 - eps,
                knuckle_length + 2 * eps,
                knuckle_id
            );

        for (y0 = left_knuckle_y)
            cylinder_y(
                y0,
                knuckle_length,
                knuckle_od + 2 * barrel_clearance
            );

        for (y = hole_y_positions)
            countersunk_hole(hole_x, y);
    }
}

module hinge_pin() {
    cylinder_y(-pin_overhang, pin_length, pin_diameter);
}

color([0.72, 0.76, 0.80])
    left_leaf();

color([0.58, 0.63, 0.68])
    right_leaf();

color([0.88, 0.88, 0.86])
    hinge_pin();