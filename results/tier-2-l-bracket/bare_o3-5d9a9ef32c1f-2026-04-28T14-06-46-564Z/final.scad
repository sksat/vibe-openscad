// L-bracket with countersunk holes
// Dimensions
WIDTH       = 50;   // X direction (common width of both flanges)
DEPTH       = 40;   // Y direction of horizontal flange
HEIGHT      = 40;   // Z direction of vertical flange
THK         = 3;    // Plate thickness

// Hole parameters
HOLE_D      = 4.5;  // Through-hole diameter (M4 clearance)
CSK_D       = 8;    // Countersink seat diameter
CSK_DEPTH   = 2;    // Countersink depth
EDGE_OFFSET = 10;   // Distance of hole-centres from side edges
$fn = 64;           // Circle resolution

difference() {
    // --- Plates -----------------------------------------------------------
    union() {
        // Horizontal flange (lies in XY plane, thickness +Z)
        cube([WIDTH, DEPTH, THK], center = false);

        // Vertical flange (stands in YZ plane, thickness –Y)
        translate([0, -THK, 0])
            cube([WIDTH, THK, HEIGHT], center = false);
    }

    // --- Countersunk holes ------------------------------------------------
    // Horizontal flange holes (axis = Z)
    for (x = [EDGE_OFFSET, WIDTH - EDGE_OFFSET]) {
        y = DEPTH / 2;

        // Through hole
        translate([x, y, -1])
            cylinder(h = THK + 2, d = HOLE_D);

        // Countersink (from top surface downward)
        translate([x, y, THK - CSK_DEPTH])
            cylinder(h = CSK_DEPTH + 1, d = CSK_D);
    }

    // Vertical flange holes (axis = Y)
    for (x = [EDGE_OFFSET, WIDTH - EDGE_OFFSET]) {
        z = HEIGHT / 2;

        // Through hole
        translate([x, -THK - 1, z])
            rotate([90, 0, 0])
                cylinder(h = THK + 2, d = HOLE_D);

        // Countersink (from outer side toward inside)
        translate([x, -THK, z])
            rotate([90, 0, 0])
                cylinder(h = CSK_DEPTH + 1, d = CSK_D);
    }
}