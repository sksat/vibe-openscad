$fn = 96;

width       = 50;
depth       = 40;
height      = 40;
thickness   = 3;

hole_d      = 4.5;
countersink_d     = 8;
countersink_depth = 2;
edge_offset = 10;
eps         = 0.01;

hole_x_positions = [
    -width / 2 + edge_offset,
     width / 2 - edge_offset
];

module bracket_body() {
    union() {
        // Horizontal flange: +Y, outer face at Z = -thickness
        translate([-width / 2, 0, -thickness])
            cube([width, depth, thickness]);

        // Vertical flange: +Z, outer face at Y = -thickness
        translate([-width / 2, -thickness, 0])
            cube([width, thickness, height]);

        // Outer corner connection
        translate([-width / 2, -thickness, -thickness])
            cube([width, thickness, thickness]);
    }
}

module horizontal_countersunk_hole(x, y) {
    // Through-hole
    translate([x, y, -thickness - eps])
        cylinder(h = thickness + 2 * eps, d = hole_d);

    // Countersink opening toward the outer, lower face
    translate([x, y, -thickness])
        cylinder(
            h  = countersink_depth,
            d1 = countersink_d,
            d2 = hole_d
        );
}

module vertical_countersunk_hole(x, z) {
    // Through-hole
    translate([x, -thickness - eps, z])
        rotate([-90, 0, 0])
            cylinder(h = thickness + 2 * eps, d = hole_d);

    // Countersink opening toward the outer, rear face
    translate([x, -thickness, z])
        rotate([-90, 0, 0])
            cylinder(
                h  = countersink_depth,
                d1 = countersink_d,
                d2 = hole_d
            );
}

difference() {
    bracket_body();

    for (x = hole_x_positions) {
        horizontal_countersunk_hole(x, depth / 2);
        vertical_countersunk_hole(x, height / 2);
    }
}