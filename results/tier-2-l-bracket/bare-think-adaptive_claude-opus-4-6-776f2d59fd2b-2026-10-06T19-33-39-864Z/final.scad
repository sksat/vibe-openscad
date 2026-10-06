$fn = 64;

// --- Parameters ---
width     = 50;   // X direction
depth     = 40;   // flange extent (Y for horizontal, Z for vertical)
thickness = 3;

// Hole parameters
through_d    = 4.5;
csink_d      = 8;
csink_depth  = 2;
edge_inset   = 10; // distance from width edge to hole centre

// Derived positions
hx = width / 2 - edge_inset;   // ±15
fc = depth / 2;                 // 20  (face centre line)
eps = 0.01;

// --- Model ---
difference() {
    union() {
        // Horizontal flange  (inner face at Z=0, outer face at Z=-thickness)
        translate([-width/2, 0, -thickness])
            cube([width, depth, thickness]);

        // Vertical flange  (inner face at Y=0, outer face at Y=-thickness)
        translate([-width/2, -thickness, 0])
            cube([width, thickness, depth]);
    }

    // -- Horizontal flange holes (drill in Z, countersink on bottom) --
    for (sx = [-1, 1]) {
        translate([sx * hx, fc, -thickness - eps]) {
            cylinder(d = through_d, h = thickness + 2 * eps);        // through hole
            cylinder(d1 = csink_d, d2 = through_d, h = csink_depth); // countersink
        }
    }

    // -- Vertical flange holes (drill in Y, countersink on back) --
    for (sx = [-1, 1]) {
        translate([sx * hx, -thickness - eps, fc])
        rotate([-90, 0, 0]) {
            cylinder(d = through_d, h = thickness + 2 * eps);        // through hole
            cylinder(d1 = csink_d, d2 = through_d, h = csink_depth); // countersink
        }
    }
}