$fn = 64;

plate_length = 30;
plate_width = 25;
plate_thickness = 2;

pin_diameter = 4;
pin_length = 32;

knuckle_length = 6;
knuckle_outer_diameter = 8;
knuckle_inner_diameter = 4.6;

through_hole_diameter = 3.2;
countersink_diameter = 6;
countersink_depth = 1;

leaf_near_x = knuckle_outer_diameter / 2 - 0.2;
leaf_far_x = leaf_near_x + plate_width;
hole_x = 21.5;

module countersunk_hole(x, y) {
    translate([x, y, -plate_thickness / 2 - 0.1])
        cylinder(
            h = plate_thickness + 0.2,
            d = through_hole_diameter
        );

    translate([x, y, plate_thickness / 2 - countersink_depth])
        cylinder(
            h = countersink_depth,
            r1 = through_hole_diameter / 2,
            r2 = countersink_diameter / 2
        );
}

module leaf_plate(side) {
    x0 = side > 0 ? leaf_near_x : -leaf_far_x;
    screw_x = side > 0 ? hole_x : -hole_x;

    difference() {
        translate([x0, 0, -plate_thickness / 2])
            cube([plate_width, plate_length, plate_thickness]);

        for (y = [7, 15, 23])
            countersunk_hole(screw_x, y);
    }
}

module knuckle(y0) {
    translate([0, y0, 0])
        rotate([-90, 0, 0])
            difference() {
                cylinder(
                    h = knuckle_length,
                    d = knuckle_outer_diameter
                );

                translate([0, 0, -0.1])
                    cylinder(
                        h = knuckle_length + 0.2,
                        d = knuckle_inner_diameter
                    );
            }
}

module left_leaf() {
    color([0.52, 0.54, 0.58])
        union() {
            leaf_plate(-1);

            for (y = [0, 12, 24])
                knuckle(y);
        }
}

module right_leaf() {
    color([0.62, 0.64, 0.68])
        union() {
            leaf_plate(1);

            for (y = [6, 18])
                knuckle(y);
        }
}

module pin_axis() {
    color([0.35, 0.37, 0.40])
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(
                    h = pin_length,
                    d = pin_diameter
                );
}

left_leaf();
right_leaf();
pin_axis();