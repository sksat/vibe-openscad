$fn = 64;

// Dimensions
width = 50;
depth = 40;
height = 40;
thickness = 3;

// Hole specs
through_d = 4.5;
csink_d = 8;
csink_depth = 2;

// Hole positions
x1 = 10;
x2 = width - 10;
y_center = depth / 2;
z_center = height / 2;

module countersunk_hole_z_up(h=thickness) {
    union() {
        cylinder(h=h + 0.2, d=through_d);
        cylinder(h=csink_depth + 0.1, d=csink_d);
    }
}

module countersunk_hole_y_pos(h=thickness) {
    rotate([90, 0, 0])
        union() {
            cylinder(h=h + 0.2, d=through_d);
            cylinder(h=csink_depth + 0.1, d=csink_d);
        }
}

difference() {
    union() {
        // Horizontal flange: extends in +Y, top surface at z=0, thickness downward
        translate([0, 0, -thickness])
            cube([width, depth, thickness]);

        // Vertical flange: extends in +Z, thickness in -Y direction
        translate([0, -thickness, 0])
            cube([width, thickness, height]);
    }

    // Horizontal flange holes (countersink on outer/bottom side)
    translate([x1, y_center, -thickness - 0.05])
        countersunk_hole_z_up(thickness + 0.1);
    translate([x2, y_center, -thickness - 0.05])
        countersunk_hole_z_up(thickness + 0.1);

    // Vertical flange holes (countersink on outer/back side, -Y)
    translate([x1, -thickness - 0.05, z_center])
        countersunk_hole_y_pos(thickness + 0.1);
    translate([x2, -thickness - 0.05, z_center])
        countersunk_hole_y_pos(thickness + 0.1);
}