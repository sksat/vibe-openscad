$fn = 96;

leaf_length      = 30;
leaf_width       = 25;
leaf_thickness   = 2;

knuckle_length   = 6;
knuckle_od       = 8;
knuckle_id       = 4.6;

pin_diameter     = 4;
pin_length       = 32;

through_diameter = 3.2;
countersink_dia  = 6;
countersink_depth = 1;

attach_overlap   = 0.2;
knuckle_radius   = knuckle_od / 2;
leaf_inner_x     = knuckle_radius - attach_overlap;

eps = 0.02;

module y_cylinder(y0, length, diameter) {
    translate([0, y0, 0])
        rotate([-90, 0, 0])
            cylinder(h = length, d = diameter);
}

module knuckle(y0) {
    difference() {
        y_cylinder(y0, knuckle_length, knuckle_od);
        y_cylinder(y0 - eps, knuckle_length + 2 * eps, knuckle_id);
    }
}

module countersunk_hole(x, y) {
    translate([x, y, -leaf_thickness])
        cylinder(
            h = leaf_thickness * 2,
            d = through_diameter
        );

    translate([x, y, leaf_thickness / 2 - countersink_depth])
        cylinder(
            h = countersink_depth + eps,
            d1 = through_diameter,
            d2 = countersink_dia
        );
}

module left_leaf() {
    difference() {
        union() {
            translate([
                -leaf_inner_x - leaf_width,
                0,
                -leaf_thickness / 2
            ])
                cube([
                    leaf_width,
                    leaf_length,
                    leaf_thickness
                ]);

            for (y0 = [0, 12, 24])
                knuckle(y0);
        }

        for (y = [7, 15, 23])
            countersunk_hole(
                -leaf_inner_x - leaf_width + 7.5,
                y
            );
    }
}

module right_leaf() {
    difference() {
        union() {
            translate([
                leaf_inner_x,
                0,
                -leaf_thickness / 2
            ])
                cube([
                    leaf_width,
                    leaf_length,
                    leaf_thickness
                ]);

            for (y0 = [6, 18])
                knuckle(y0);
        }

        for (y = [7, 15, 23])
            countersunk_hole(
                leaf_inner_x + leaf_width - 7.5,
                y
            );
    }
}

module hinge_pin() {
    y_cylinder(-1, pin_length, pin_diameter);
}

color([0.68, 0.70, 0.73])
    left_leaf();

color([0.58, 0.61, 0.65])
    right_leaf();

color([0.82, 0.84, 0.86])
    hinge_pin();