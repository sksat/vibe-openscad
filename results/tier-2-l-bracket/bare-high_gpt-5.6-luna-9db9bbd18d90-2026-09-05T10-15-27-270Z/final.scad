$fn = 96;

// Dimensions
width       = 50;
flange_len  = 40;
thickness   = 3;

// Hole dimensions
hole_d      = 4.5;
csk_d       = 8;
csk_depth   = 2;
edge_offset = 10;

hole_x = width / 2 - edge_offset;
hole_pos = [ -hole_x, hole_x ];
face_center = flange_len / 2;

// L-bracket body
module bracket_body() {
    union() {
        // Horizontal flange: inner surface at Z = 0
        translate([-width / 2, 0, -thickness])
            cube([width, flange_len, thickness]);

        // Vertical flange: inner surface at Y = 0
        translate([-width / 2, -thickness, 0])
            cube([width, thickness, flange_len]);

        // Square bend connecting both flanges
        translate([-width / 2, -thickness, -thickness])
            cube([width, thickness, thickness]);
    }
}

// Countersunk hole through the horizontal flange
module horizontal_countersink(x, y) {
    // Through hole
    translate([x, y, -thickness - 1])
        cylinder(
            h = thickness + 2,
            d = hole_d
        );

    // Countersink on the outer face, Z = -3
    translate([x, y, -thickness])
        cylinder(
            h = csk_depth,
            r1 = csk_d / 2,
            r2 = hole_d / 2
        );
}

// Countersunk hole through the vertical flange
module vertical_countersink(x, z) {
    // Through hole
    translate([x, -thickness - 1, z])
        rotate([-90, 0, 0])
            cylinder(
                h = thickness + 2,
                d = hole_d
            );

    // Countersink on the outer face, Y = -3
    translate([x, -thickness, z])
        rotate([-90, 0, 0])
            cylinder(
                h = csk_depth,
                r1 = csk_d / 2,
                r2 = hole_d / 2
            );
}

difference() {
    bracket_body();

    // Horizontal flange holes
    for (x = hole_pos)
        horizontal_countersink(x, face_center);

    // Vertical flange holes
    for (x = hole_pos)
        vertical_countersink(x, face_center);
}