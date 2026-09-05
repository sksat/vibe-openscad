$fn = 96;

width = 50;
depth = 40;
height = 40;
thickness = 3;

through_diameter = 4.5;
countersink_diameter = 8;
countersink_depth = 2;

edge_inset = 10;
epsilon = 0.01;

hole_x_positions = [edge_inset, width - edge_inset];

module l_bracket() {
    union() {
        translate([0, 0, -thickness])
            cube([width, depth, thickness]);

        translate([0, -thickness, 0])
            cube([width, thickness, height]);

        translate([0, -thickness, -thickness])
            cube([width, thickness, thickness]);
    }
}

module horizontal_countersink_hole(x) {
    union() {
        translate([x, depth / 2, -thickness - epsilon])
            cylinder(
                h = thickness + 2 * epsilon,
                r = through_diameter / 2
            );

        translate([x, depth / 2, -thickness])
            cylinder(
                h = countersink_depth,
                r1 = countersink_diameter / 2,
                r2 = through_diameter / 2
            );
    }
}

module vertical_countersink_hole(x) {
    union() {
        translate([x, -thickness - epsilon, height / 2])
            rotate([-90, 0, 0])
                cylinder(
                    h = thickness + 2 * epsilon,
                    r = through_diameter / 2
                );

        translate([x, -thickness, height / 2])
            rotate([-90, 0, 0])
                cylinder(
                    h = countersink_depth,
                    r1 = countersink_diameter / 2,
                    r2 = through_diameter / 2
                );
    }
}

difference() {
    l_bracket();

    for (x = hole_x_positions) {
        horizontal_countersink_hole(x);
        vertical_countersink_hole(x);
    }
}