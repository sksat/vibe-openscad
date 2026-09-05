$fn = 64;

// ------------------------------------------------------------
// Small furniture butt hinge
// Open position: 180 degrees
// Units: mm
// ------------------------------------------------------------

// Main dimensions
leaf_length      = 30;
leaf_width       = 25;
leaf_thickness   = 2;

pin_diameter     = 4;
pin_length       = 32;

knuckle_od       = 8;
knuckle_id       = 4.6;
knuckle_length   = 6;
knuckle_count    = 5;

hole_diameter    = 3.2;
csk_diameter     = 6;
csk_depth        = 1;
hole_pitch       = 8;
hole_x_offset    = 18;

module cylinder_y(d, length, y_start = 0) {
    translate([0, y_start, 0])
        rotate([-90, 0, 0])
            cylinder(d = d, h = length);
}

module countersunk_hole(x, y) {
    // Through hole
    translate([x, y, -leaf_thickness / 2 - 0.1])
        cylinder(d = hole_diameter, h = leaf_thickness + 0.2);

    // Countersink from upper surface
    translate([x, y, leaf_thickness / 2 - csk_depth])
        cylinder(
            h  = csk_depth + 0.05,
            d1 = hole_diameter,
            d2 = csk_diameter
        );
}

module knuckle(y_start) {
    difference() {
        cylinder_y(knuckle_od, knuckle_length, y_start);

        translate([0, y_start - 0.05, 0])
            rotate([-90, 0, 0])
                cylinder(d = knuckle_id, h = knuckle_length + 0.1);
    }
}

module left_leaf() {
    difference() {
        union() {
            // Leaf plate: X < 0
            translate([-leaf_width, 0, -leaf_thickness / 2])
                cube([leaf_width, leaf_length, leaf_thickness]);

            // Left leaf knuckles: lower, center, upper
            knuckle(0);
            knuckle(12);
            knuckle(24);
        }

        // Mounting holes
        countersunk_hole(-hole_x_offset, 7);
        countersunk_hole(-hole_x_offset, 15);
        countersunk_hole(-hole_x_offset, 23);
    }
}

module right_leaf() {
    difference() {
        union() {
            // Leaf plate: X > 0
            translate([0, 0, -leaf_thickness / 2])
                cube([leaf_width, leaf_length, leaf_thickness]);

            // Right leaf knuckles: alternating positions
            knuckle(6);
            knuckle(18);
        }

        // Mounting holes
        countersunk_hole(hole_x_offset, 7);
        countersunk_hole(hole_x_offset, 15);
        countersunk_hole(hole_x_offset, 23);
    }
}

module hinge_pin() {
    // Pin protrudes 1 mm beyond both knuckle ends
    translate([0, -1, 0])
        rotate([-90, 0, 0])
            cylinder(d = pin_diameter, h = pin_length);
}

// ------------------------------------------------------------
// Completed hinge assembly
// ------------------------------------------------------------

color([0.45, 0.45, 0.48])
    left_leaf();

color([0.50, 0.50, 0.53])
    right_leaf();

color([0.25, 0.25, 0.28])
    hinge_pin();