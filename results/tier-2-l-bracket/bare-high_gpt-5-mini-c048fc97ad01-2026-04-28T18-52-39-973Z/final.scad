// L-bracket with countersunk holes (inner corner at origin)
// Horizontal flange: +Y direction
// Vertical flange: +Z direction

$fn = 64;

width = 50;        // X dimension
depth = 40;        // horizontal flange depth (Y)
height = 40;       // vertical flange height (Z)
thickness = 3;     // plate thickness

hole_d = 4.5;      // through hole diameter for M4
cs_d = 8;          // countersink diameter
cs_depth = 2;      // countersink depth
edge_offset = 10;  // distance from face edges for holes

module bracket() {
    union() {
        // horizontal flange (X × Y × Z)
        translate([0, 0, 0]) cube([width, depth, thickness]);
        // vertical flange (X × Y(thickness) × Z)
        translate([0, 0, 0]) cube([width, thickness, height]);
    }
}

module horiz_countersunk_hole(x, y) {
    // countersink (flat-bottom) on outside (top) of horizontal flange
    translate([x, y, thickness - cs_depth])
        cylinder(h = cs_depth, r = cs_d/2);
    // through hole
    translate([x, y, -5])
        cylinder(h = thickness + 10, r = hole_d/2);
}

module vert_countersunk_hole(x, z) {
    // countersink (flat-bottom) on outside (outer Y face) of vertical flange
    translate([x, thickness - cs_depth/2, z])
        rotate([90, 0, 0])
            cylinder(h = cs_depth, r = cs_d/2, center = true);
    // through hole (axis along Y)
    translate([x, thickness/2, z])
        rotate([90, 0, 0])
            cylinder(h = 200, r = hole_d/2, center = true);
}

difference() {
    bracket();

    // horizontal flange holes (centerline along X)
    for (ypos = [edge_offset, depth - edge_offset]) {
        horiz_countersunk_hole(width/2, ypos);
    }

    // vertical flange holes (centerline along X)
    for (zpos = [edge_offset, height - edge_offset]) {
        vert_countersunk_hole(width/2, zpos);
    }
}