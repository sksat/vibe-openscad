$fn = 96;

width      = 50;
depth      = 40;
height     = 40;
thickness  = 3;

hole_d     = 4.5;
csk_d      = 8;
csk_depth  = 2;
edge_offset = 10;
eps         = 0.02;

hole_x_positions = [
    -width / 2 + edge_offset,
     width / 2 - edge_offset
];

module bracket_body() {
    union() {
        // Horizontal flange: extends in +Y, thickness toward -Z
        translate([-width / 2, -thickness, -thickness])
            cube([width, depth + thickness, thickness]);

        // Vertical flange: extends in +Z, thickness toward -Y
        translate([-width / 2, -thickness, -thickness])
            cube([width, thickness, height + thickness]);
    }
}

module horizontal_countersunk_hole(x, y) {
    union() {
        translate([x, y, -thickness - eps])
            cylinder(h = thickness + 2 * eps, d = hole_d);

        translate([x, y, -thickness - eps])
            cylinder(h = eps, d = csk_d);

        translate([x, y, -thickness])
            cylinder(
                h  = csk_depth,
                d1 = csk_d,
                d2 = hole_d
            );
    }
}

module vertical_countersunk_hole(x, z) {
    union() {
        translate([x, -thickness - eps, z])
            rotate([-90, 0, 0])
                cylinder(h = thickness + 2 * eps, d = hole_d);

        translate([x, -thickness - eps, z])
            rotate([-90, 0, 0])
                cylinder(h = eps, d = csk_d);

        translate([x, -thickness, z])
            rotate([-90, 0, 0])
                cylinder(
                    h  = csk_depth,
                    d1 = csk_d,
                    d2 = hole_d
                );
    }
}

difference() {
    bracket_body();

    for (x = hole_x_positions)
        horizontal_countersunk_hole(x, depth / 2);

    for (x = hole_x_positions)
        vertical_countersunk_hole(x, height / 2);
}