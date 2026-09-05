$fn = 96;

width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_diameter = 4.5;
countersink_diameter = 8;
countersink_depth = 2;
edge_offset = 10;
epsilon = 0.01;

difference() {
    union() {
        // Horizontal flange
        translate([-width / 2, 0, -thickness])
            cube([width, depth, thickness]);

        // Vertical flange
        translate([-width / 2, -thickness, 0])
            cube([width, thickness, height]);

        // Corner bend
        translate([-width / 2, -thickness, -thickness])
            cube([width, thickness, thickness]);
    }

    for (x = [-width / 2 + edge_offset, width / 2 - edge_offset]) {
        // Horizontal flange through hole
        translate([x, depth / 2, -thickness - epsilon])
            cylinder(
                h = thickness + 2 * epsilon,
                d = hole_diameter
            );

        // Horizontal flange countersink
        translate([x, depth / 2, -thickness])
            cylinder(
                h = countersink_depth,
                d1 = countersink_diameter,
                d2 = hole_diameter
            );

        // Vertical flange through hole
        translate([x, -thickness - epsilon, height / 2])
            rotate([-90, 0, 0])
                cylinder(
                    h = thickness + 2 * epsilon,
                    d = hole_diameter
                );

        // Vertical flange countersink
        translate([x, -thickness, height / 2])
            rotate([-90, 0, 0])
                cylinder(
                    h = countersink_depth,
                    d1 = countersink_diameter,
                    d2 = hole_diameter
                );
    }
}