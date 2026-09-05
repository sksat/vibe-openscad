$fn = 96;

leaf_length    = 30;
leaf_width     = 25;
leaf_thickness = 2;

knuckle_count  = 5;
knuckle_length = leaf_length / knuckle_count;
knuckle_outer_d = 8;
knuckle_inner_d = 4.6;

pin_diameter   = 4;
pin_overhang   = 1;
pin_length     = leaf_length + 2 * pin_overhang;

through_hole_diameter = 3.2;
countersink_diameter  = 6;
countersink_depth     = 1;
hole_pitch            = 8;
hole_edge_inset       = 5;

leaf_root_x = knuckle_outer_d / 2;
hole_x      = leaf_root_x + leaf_width - hole_edge_inset;
hole_y      = [
    leaf_length / 2 - hole_pitch,
    leaf_length / 2,
    leaf_length / 2 + hole_pitch
];

cutter_eps = 0.01;

left_knuckle_starts  = [0, 2 * knuckle_length, 4 * knuckle_length];
right_knuckle_starts = [knuckle_length, 3 * knuckle_length];

module cylinder_y(h, d) {
    rotate([-90, 0, 0])
        cylinder(h = h, d = d, center = false);
}

module leaf_plate(side) {
    x_start = (side > 0)
        ? leaf_root_x
        : (-leaf_root_x - leaf_width);

    difference() {
        translate([x_start, 0, -leaf_thickness / 2])
            cube([leaf_width, leaf_length, leaf_thickness]);

        for (yy = hole_y) {
            translate([
                side * hole_x,
                yy,
                -leaf_thickness / 2 - cutter_eps
            ])
                cylinder(
                    h = leaf_thickness + 2 * cutter_eps,
                    d = through_hole_diameter,
                    center = false
                );

            translate([
                side * hole_x,
                yy,
                leaf_thickness / 2 - countersink_depth
            ])
                cylinder(
                    h = countersink_depth,
                    d1 = through_hole_diameter,
                    d2 = countersink_diameter,
                    center = false
                );
        }
    }
}

module knuckle(y_start) {
    translate([0, y_start, 0])
        difference() {
            cylinder_y(knuckle_length, knuckle_outer_d);

            translate([0, -cutter_eps, 0])
                cylinder_y(
                    knuckle_length + 2 * cutter_eps,
                    knuckle_inner_d
                );
        }
}

module left_part() {
    color([0.48, 0.50, 0.54])
        union() {
            leaf_plate(-1);

            for (y_start = left_knuckle_starts) {
                knuckle(y_start);
            }
        }
}

module right_part() {
    color([0.48, 0.50, 0.54])
        union() {
            leaf_plate(1);

            for (y_start = right_knuckle_starts) {
                knuckle(y_start);
            }
        }
}

module pin_part() {
    color([0.72, 0.74, 0.78])
        translate([0, -pin_overhang, 0])
            cylinder_y(pin_length, pin_diameter);
}

module assembly() {
    left_part();
    right_part();
    pin_part();
}

assembly();