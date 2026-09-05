$fn = 64;

plate_length = 30;
plate_width  = 25;
plate_thickness = 2;

pin_diameter = 4;
pin_radius = pin_diameter / 2;
pin_length = 32;

knuckle_length = 6;
knuckle_outer_diameter = 8;
knuckle_outer_radius = knuckle_outer_diameter / 2;
knuckle_inner_diameter = 4.6;
knuckle_inner_radius = knuckle_inner_diameter / 2;

hole_diameter = 3.2;
hole_radius = hole_diameter / 2;
countersink_diameter = 6;
countersink_radius = countersink_diameter / 2;
countersink_depth = 1;

plate_z0 = -plate_thickness / 2;
hole_y_positions = [7, 15, 23];

module cylinder_y(y, length, radius) {
    translate([0, y, 0])
        rotate([-90, 0, 0])
            cylinder(h = length, r = radius);
}

module knuckle_outer(y) {
    cylinder_y(y, knuckle_length, knuckle_outer_radius);
}

module knuckle_bore(y, extra = 0.2) {
    translate([0, y - extra, 0])
        rotate([-90, 0, 0])
            cylinder(
                h = knuckle_length + 2 * extra,
                r = knuckle_inner_radius
            );
}

module mounting_hole(x, y) {
    translate([x, y, plate_z0 - 1])
        cylinder(
            h = plate_thickness + 2,
            r = hole_radius
        );

    translate([x, y, plate_z0 + plate_thickness - countersink_depth])
        cylinder(
            h = countersink_depth + 0.01,
            r1 = hole_radius,
            r2 = countersink_radius
        );
}

module left_leaf() {
    difference() {
        union() {
            translate([-plate_width, 0, plate_z0])
                cube([plate_width, plate_length, plate_thickness]);

            knuckle_outer(0);
            knuckle_outer(12);
            knuckle_outer(24);
        }

        knuckle_bore(0);
        knuckle_bore(12);
        knuckle_bore(24);

        for (y = hole_y_positions)
            mounting_hole(-17, y);
    }
}

module right_leaf() {
    difference() {
        union() {
            translate([0, 0, plate_z0])
                cube([plate_width, plate_length, plate_thickness]);

            knuckle_outer(6);
            knuckle_outer(18);
        }

        knuckle_bore(6);
        knuckle_bore(18);

        for (y = hole_y_positions)
            mounting_hole(17, y);
    }
}

module hinge_pin() {
    cylinder_y(-1, pin_length, pin_radius);
}

color("dimgray")
    left_leaf();

color("silver")
    right_leaf();

color("lightgray")
    hinge_pin();