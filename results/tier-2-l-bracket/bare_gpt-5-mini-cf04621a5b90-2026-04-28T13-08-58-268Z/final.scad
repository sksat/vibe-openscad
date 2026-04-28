// OpenSCAD: L-bracket with countersunk holes for M4 screws
// Inner corner at origin. Horizontal flange extends +Y, vertical flange extends +Z.

$fn = 64;

width = 50;     // X dimension
depth = 40;     // Y dimension for horizontal flange
height = 40;    // Z dimension for vertical flange
thickness = 3;  // plate thickness for both flanges

// Hole parameters
clearance_d = 4.5;    // through hole diameter for M4
countersink_d = 8;    // counterbore diameter
countersink_depth = 2;

module l_bracket() {
    // Horizontal flange: spans X:0..width, Y:0..depth, Z:0..thickness
    // Vertical flange: spans X:0..width, Y:0..thickness, Z:0..height
    union() {
        cube([width, depth, thickness], center=false);
        cube([width, thickness, height], center=false);
    }
}

module countersunk_through_z(x, y) {
    // Countersink on outer (+Z) side of horizontal flange.
    // Countersink: cylinder top at Z=thickness, depth into plate = countersink_depth
    translate([x, y, thickness - countersink_depth])
        cylinder(h=countersink_depth, d=countersink_d);
    // Through hole: extend well beyond plate to ensure cut-through
    translate([x, y, -10])
        cylinder(h=30 + thickness, d=clearance_d);
}

module countersunk_through_y(x, z) {
    // Countersink on outer (+Y) side of vertical flange.
    // We'll orient a cylinder along Y by rotating around X by 90 degrees.
    // Countersink: from Y = thickness - countersink_depth to Y = thickness
    rotate([90,0,0])
        translate([x, thickness - countersink_depth, z])
            cylinder(h=countersink_depth, d=countersink_d);
    // Through hole along Y: extend well beyond to cut through
    rotate([90,0,0])
        translate([x, -10, z])
            cylinder(h=30 + thickness, d=clearance_d);
}

// Hole positions: along each face centerline
x_positions = [10, width - 10];
y_center = depth / 2;
z_center = height / 2;

difference() {
    l_bracket();

    // Horizontal flange holes (axis Z), countersink on +Z side
    for (x_pos = x_positions)
        countersunk_through_z(x_pos, y_center);

    // Vertical flange holes (axis Y), countersink on +Y side
    for (x_pos = x_positions)
        countersunk_through_y(x_pos, z_center);
}