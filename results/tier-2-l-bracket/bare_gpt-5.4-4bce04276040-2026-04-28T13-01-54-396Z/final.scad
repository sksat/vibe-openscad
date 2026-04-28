$fn = 64;

// Parameters
width = 50;
depth = 40;
height = 40;
thickness = 3;

through_d = 4.5;
csink_d = 8;
csink_depth = 2;

edge_offset = 10;
x1 = edge_offset;
x2 = width - edge_offset;

// Countersunk hole module (simple counterbore-style recess as requested)
module countersunk_hole(len) {
    union() {
        cylinder(h = len, d = through_d);
        cylinder(h = csink_depth, d = csink_d);
    }
}

difference() {
    union() {
        // Horizontal flange: extends in +Y, thickness in +Z
        cube([width, depth, thickness]);

        // Vertical flange: extends in +Z, thickness in -Y (outer face at y = -thickness)
        translate([0, -thickness, 0])
            cube([width, thickness, height]);
    }

    // Horizontal flange holes (outer side = top, +Z)
    for (x = [x1, x2]) {
        translate([x, depth/2, thickness])
            rotate([180, 0, 0])
                countersunk_hole(thickness);
    }

    // Vertical flange holes (outer side = back, -Y)
    for (x = [x1, x2]) {
        translate([x, -thickness, height/2])
            rotate([-90, 0, 0])
                countersunk_hole(thickness);
    }
}