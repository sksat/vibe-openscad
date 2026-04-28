$fn = 96;

width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_d = 4.5;
countersink_d = 8;
countersink_depth = 2;

edge_offset = 10;
eps = 0.01;

hole_x_positions = [
    -width / 2 + edge_offset,
     width / 2 - edge_offset
];

module horizontal_countersunk_hole(x, y) {
    translate([x, y, -thickness - eps])
        cylinder(d = hole_d, h = thickness + 2 * eps);

    translate([x, y, -thickness])
        cylinder(d1 = countersink_d, d2 = hole_d, h = countersink_depth + eps);
}

module vertical_countersunk_hole(x, z) {
    translate([x, -thickness - eps, z])
        rotate([-90, 0, 0])
            cylinder(d = hole_d, h = thickness + 2 * eps);

    translate([x, -thickness, z])
        rotate([-90, 0, 0])
            cylinder(d1 = countersink_d, d2 = hole_d, h = countersink_depth + eps);
}

difference() {
    union() {
        translate([-width / 2, 0, -thickness])
            cube([width, depth, thickness]);

        translate([-width / 2, -thickness, 0])
            cube([width, thickness, height]);

        translate([-width / 2, -thickness, -thickness])
            cube([width, thickness, thickness]);
    }

    for (x = hole_x_positions) {
        horizontal_countersunk_hole(x, depth / 2);
        vertical_countersunk_hole(x, height / 2);
    }
}