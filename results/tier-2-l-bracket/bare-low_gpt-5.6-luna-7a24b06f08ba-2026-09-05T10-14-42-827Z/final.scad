$fn = 96;

width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_d = 4.5;
countersink_d = 8;
countersink_depth = 2;

hole_x = [10, width - 10];
hole_y = depth / 2;
hole_z = height / 2;

difference() {
    union() {
        // Horizontal flange: +Y direction
        cube([width, depth, thickness], center = false);

        // Vertical flange: +Z direction
        translate([0, -thickness, 0])
            cube([width, thickness, height], center = false);

        // Bent corner material
        translate([0, -thickness, -thickness])
            cube([width, thickness, thickness], center = false);
    }

    // Countersunk holes in horizontal flange
    for (x = hole_x) {
        translate([x, hole_y, -thickness - 0.1])
            cylinder(
                h = thickness + 0.2,
                d = hole_d
            );

        translate([x, hole_y, -thickness])
            cylinder(
                h = countersink_depth,
                d1 = countersink_d,
                d2 = hole_d
            );
    }

    // Countersunk holes in vertical flange
    for (x = hole_x) {
        translate([x, -thickness - 0.1, hole_z])
            rotate([90, 0, 0])
                cylinder(
                    h = thickness + 0.2,
                    d = hole_d
                );

        translate([x, -thickness, hole_z])
            rotate([90, 0, 0])
                cylinder(
                    h = countersink_depth,
                    d1 = hole_d,
                    d2 = countersink_d
                );
    }
}