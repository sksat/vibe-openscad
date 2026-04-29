// L-Bracket Dimensions
T = 3;        // Thickness of both flanges (mm)
L_X = 50;     // Length along X axis (Width)
L_Y_H = 40;   // Depth/Length for Horizontal flange (Y dimension)
L_Z_V = 40;   // Height for Vertical flange (Z dimension)

// Hole Parameters (M4 bolt, countersunk)
D_HOLE = 5.0; // Full bore diameter (Φ5mm minimum clearance)
R_HOLE_BASE = 8.0; // Countersink base radius/diameter
H_HOLE = 2.0;    // Countersink depth

// Hole Placement Parameters
OFFSET_FROM_EDGE = 10; // Distance from the edge of the flange (10mm)
NUM_HOLES = 2;       // Number of holes per face

// --- 1. Main Structure Definition ---

// Horizontal Flange (X-Y plane, thickness along Z)
// Extends from [0, 50] on X, [0, 40] on Y, and has height 3 on Z.
horizontal_flange = translate([0, 0, 0]) cube([L_X, L_Y_H, T]);

// Vertical Flange (X-Z plane, thickness along Y)
// Extends from [0, 50] on X, [0, 40] on Z, and has thickness 3 on Y.
vertical_flange = translate([0, 0, 0]) cube([L_X, T, L_Z_V]);


// --- 2. Hole Generation Function ---

/* 
 * Generates the geometry for one countersunk hole cut.
 * @param [x, y, z] - Center position of the hole bore (starting corner).
 * @param target_thickness - The dimension that defines the depth of the material being cut through.
 */
module generate_hole(center_x, center_y, center_z, target_thickness) {
    // 1. Full Bore Cutter: Cuts through the thickness and slightly beyond for safety.
    translate([center_x - D_HOLE/2, center_y - D_HOLE/2, center_z - D_HOLE/2])
    cube([D_HOLE, D_HOLE * 1.5, target_thickness + 2]);

    // 2. Countersink Cutter: Creates the flat bottom of the hole.
    translate([center_x - R_HOLE_BASE/2, center_y - R_HOLE_BASE/2, center_z - H_HOLE])
    cube([R_HOLE_BASE * 2, R_HOLE_BASE * 1.5, H_HOLE]);
}


// --- 3. Hole Placement Calculation and Execution ---

// A) Holes on the Outer Face of Horizontal Flange (Y=40 side)
// Location: X = 10mm/2 - 10mm, Y = 40 - 10, Z must be within [0, 3]
// The hole depth is constrained by the vertical flange thickness T=3.
x_h1 = OFFSET_FROM_EDGE; // Near one edge (X=10)
y_h = L_Y_H - OFFSET_FROM_EDGE; // Far side (Y=30)
z_start = 0;

// Hole pair 1: X=10, Y=30. The depth is limited by T=3 of the vertical flange.
translate([x_h1, y_h, z_start]) generate_hole(x_h1, y_h, z_start, T);

// Hole pair 2: X=40, Y=30.
translate([L_X - x_h1, y_h, z_start]) generate_hole(L_X - x_h1, y_h, z_start, T);


// B) Holes on the Outer Face of Vertical Flange (Z=40 side)
// Location: X = 10mm/2 - 10mm, Z = 40 - 10. Y must be within [0, 3].
x_v = OFFSET_FROM_EDGE; // Near one edge (X=10)
y_start = 0;
z_h = L_Z_V - OFFSET_FROM_EDGE; // Far side (Z=30)

// Hole pair 3: X=10, Z=30. The depth is limited by T=3 of the horizontal flange.
translate([x_v, y_start, z_h]) generate_hole(x_v, y_start, z_h, T);

// Hole pair 4: X=40, Z=30.
translate([L_X - x_v, y_start, z_h]) generate_hole(L_X - x_v, y_start, z_h, T);


// --- 4. Final Assembly and Subtraction ---

difference() {
    // Start with the combined solid body
    union() {
        horizontal_flange;
        vertical_flange;
    }

    // Subtract all generated holes (the cutter volumes)
    translate([0, 0, 0]) union() {
        // Holes for Horizontal Flange Face (Y=40 side): Cutting through vertical thickness (T=3).
        // The geometry is defined by the hole generation calls above.
        generate_hole(x_h1, y_h, z_start, T); // Hole 1
        generate_hole(L_X - x_h1, y_h, z_start, T); // Hole 2

        // Holes for Vertical Flange Face (Z=40 side): Cutting through horizontal thickness (T=3).
        // The geometry is defined by the hole generation calls above.
        generate_hole(x_v, y_start, z_h, T); // Hole 3
        generate_hole(L_X - x_v, y_start, z_h, T); // Hole 4
    }
}