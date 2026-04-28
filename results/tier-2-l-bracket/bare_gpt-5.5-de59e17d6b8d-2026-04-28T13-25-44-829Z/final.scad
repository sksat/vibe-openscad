$fn = 96;

width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_d = 4.5;
countersink_d = 8;
countersink_depth = 2;

edge_inset = 10;

hole_x_positions = [
    -width / 2 + edge_inset,
     width / 2 - edge_inset
];

module l_bracket_body() {
    union() {
        translate([-width / 2, 0, -thickness])
            cube([width, depth, thickness]);

        translate([-width / 2, -thickness, 0])
            cube([width, thickness, height]);

        translate([-width / 2, -thickness, -thickness])
            cube([width, thickness, thickness]);
    }
}

module horizontal_countersunk_hole(x, y) {
    translate([x, y, -thickness / 2])
        cylinder(h = thickness + 2, d = hole_d, center = true);

    translate([x, y, -thickness])
        cylinder(h = countersink_depth, d1 = countersink_d, d2 = hole_d);
}

module vertical_countersunk_hole(x, z) {
    translate([x, -thickness / 2, z])
        rotate([90, 0, 0])
            cylinder(h = thickness + 2, d = hole_d, center = true);

    translate([x, -thickness + countersink_depth, z])
        rotate([90, 0, 0])
            cylinder(h = countersink_depth, d1 = hole_d, d2 = countersink_d);
}

difference() {
    l_bracket_body();

    for (x = hole_x_positions) {
        horizontal_countersunk_hole(x, depth / 2);
        vertical_countersunk_hole(x, height / 2);
    }
}