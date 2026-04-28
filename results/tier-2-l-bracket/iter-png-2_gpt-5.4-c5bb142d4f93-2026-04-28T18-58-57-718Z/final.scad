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
        cylinder(h=csink_depth, d=csink_d);
        translate([0, 0, csink_depth])
            cylinder(h=h - csink_depth, d=through_d);
    }
}

module countersunk_hole_y_pos(h=thickness) {
    rotate([90, 0, 0])
        union() {
            cylinder(h=csink_depth, d=csink_d);
            translate([0, 0, csink_depth])
                cylinder(h=h - csink_depth, d=through_d);
        }
}

difference() {
    union() {
        // Horizontal flange: inner top face at z=0, extends +Y, thickness toward -Z
        translate([0, 0, -thickness])
            cube([width, depth, thickness]);

        // Vertical flange: inner front face at y=0, extends +Z, thickness toward -Y
        translate([0, -thickness, 0])
            cube([width, thickness, height]);
    }

    // Horizontal flange holes: on centerline, 10mm from left/right edges,
    // countersink on outer face (bottom, -Z)
    translate([x1, y_center, -thickness])
        mirror([0, 0, 1])
            countersunk_hole_z_up(thickness);
    translate([x2, y_center, -thickness])
        mirror([0, 0, 1])
            countersunk_hole_z_up(thickness);

    // Vertical flange holes: on centerline, 10mm from left/right edges,
    // countersink on outer face (back, -Y)
    translate([x1, -thickness, z_center])
        mirror([0, 1, 0])
            countersunk_hole_y_pos(thickness);
    translate([x2, -thickness, z_center])
        mirror([0, 1, 0])
            countersunk_hole_y_pos(thickness);
}