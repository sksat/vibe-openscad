// L-bracket dimensions
width  = 50;
depth  = 40;
height = 40;
thick  = 3;

// Hole dimensions
hole_d       = 4.5;
csk_d        = 8;
csk_depth    = 2;
edge_offset  = 10;
hole_x       = width / 2 - edge_offset;

$fn = 64;

// Horizontal flange hole: countersink faces downward (-Z)
module horizontal_hole(x, y) {
    translate([x, y, -thick - 0.1])
        cylinder(h = thick + 0.2, d = hole_d);

    translate([x, y, -thick])
        cylinder(h = csk_depth + 0.01, d1 = csk_d, d2 = hole_d);
}

// Vertical flange hole: countersink faces outward (-Y)
module vertical_hole(x, z) {
    translate([x, -thick - 0.1, z])
        rotate([-90, 0, 0])
            cylinder(h = thick + 0.2, d = hole_d);

    translate([x, -thick, z])
        rotate([-90, 0, 0])
            cylinder(h = csk_depth + 0.01, d1 = csk_d, d2 = hole_d);
}

difference() {
    union() {
        // Horizontal flange: extends in +Y direction
        translate([-width / 2, 0, -thick])
            cube([width, depth, thick]);

        // Vertical flange: extends in +Z direction
        translate([-width / 2, -thick, 0])
            cube([width, thick, height]);

        // Solid corner connection
        translate([-width / 2, -thick, -thick])
            cube([width, thick, thick]);
    }

    for (x = [-hole_x, hole_x]) {
        horizontal_hole(x, depth / 2);
        vertical_hole(x, height / 2);
    }
}