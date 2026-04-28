// L-bracket with countersunk M4 holes
//------------------------------------------------
WIDTH       = 50;   // common width of both flanges (X)
DEPTH       = 40;   // depth of horizontal flange   (Y)
HEIGHT      = 40;   // height of  vertical flange   (Z)
THK         = 3;    // plate thickness

// Hole parameters
HOLE_D      = 4.5;  // through-hole diameter (M4 clearance)
CSK_D       = 8;    // countersink seat diameter
CSK_DEPTH   = 2;    // countersink depth
EDGE_OFF    = 10;   // distance of hole centres from left/right edges
$fn         = 64;   // circle quality

// Small extra length for subtraction robustness
EPS = 0.2;

//------------------------------------------------
difference() {

    // ----- plates ---------------------------------------------------------
    union() {
        // horizontal flange (XY plane, thickness +Z)
        cube([WIDTH, DEPTH, THK], center = false);

        // vertical flange (XZ plane, thickness –Y)
        translate([0, -THK, 0])
            cube([WIDTH, THK, HEIGHT], center = false);
    }

    // ----- holes ----------------------------------------------------------

    // horizontal flange holes (axis = Z)
    for (x = [EDGE_OFF, WIDTH - EDGE_OFF]) {
        y = DEPTH / 2;

        // through-hole
        translate([x, y, -EPS])
            cylinder(h = THK + 2*EPS, d = HOLE_D);

        // countersink (from top surface downward)
        translate([x, y, THK - CSK_DEPTH])
            cylinder(h = CSK_DEPTH, d = CSK_D);
    }

    // vertical flange holes (axis = Y)
    for (x = [EDGE_OFF, WIDTH - EDGE_OFF]) {
        z = HEIGHT / 2;

        // through-hole
        translate([x, -THK - EPS, z])
            rotate([90, 0, 0])
                cylinder(h = THK + 2*EPS, d = HOLE_D);

        // countersink (from outer face inward)
        translate([x, -THK, z])
            rotate([90, 0, 0])
                cylinder(h = CSK_DEPTH, d = CSK_D);
    }
}