// ===============================================
//                Parameters
// ===============================================

// --- Bracket Dimensions ---
width     = 50;  // Width on X-axis
depth     = 40;  // Horizontal flange depth on Y-axis
height    = 40;  // Vertical flange height on Z-axis
thickness = 3;   // Thickness of the flanges

// --- M4 Countersunk Hole Dimensions ---
hole_dia  = 4.5; // Through-hole diameter
cs_dia    = 8;   // Countersink top diameter
cs_depth  = 2;   // Countersink depth

// --- Hole Positioning ---
// X-coordinates for the two holes on each flange
hole_pos_x_list = [10, width - 10]; 
// Y-coordinate for holes on the horizontal flange (centerline)
hole_pos_y = depth / 2;
// Z-coordinate for holes on the vertical flange (centerline)
hole_pos_z = height / 2;

// --- Rendering Quality ---
$fn = 64;


// ===============================================
//           Cutter Module Definition
// ===============================================

// Module to create a reusable countersink cutter shape.
// The cutter is created along the Z-axis.
module countersink_cutter(length) {
    // A small epsilon to ensure clean subtraction
    eps = 0.1;
    
    // Countersink cone (frustum)
    cylinder(h = cs_depth, d1 = cs_dia, d2 = hole_dia);
    
    // Through-hole body
    // This cylinder starts at the same base as the cone (z=0)
    // to ensure they form a single solid for subtraction.
    cylinder(h = length + eps, d = hole_dia);
}


// ===============================================
//                  Model
// ===============================================

difference() {
    
    // 1. Create the main body of the L-bracket
    // The inner corner is at the origin [0, 0, 0].
    union() {
        // Horizontal flange: Extends from origin in +Y direction.
        // Occupies space: x=[0,width], y=[0,depth], z=[0,thickness]
        cube([width, depth, thickness]);
        
        // Vertical flange: Extends from origin in +Z direction.
        // Occupies space: x=[0,width], y=[0,thickness], z=[0,height]
        cube([width, thickness, height]);
    }
    
    // 2. Create and subtract the countersunk holes
    
    // --- Holes on the horizontal flange ---
    // Countersinks are on the outer (top) face, which is the plane z=thickness.
    for (x_pos = hole_pos_x_list) {
        // Move the cutter to the top surface and rotate it to point down (-Z).
        translate([x_pos, hole_pos_y, thickness])
        rotate(a=[180, 0, 0]) {
            countersink_cutter(length = thickness);
        }
    }
    
    // --- Holes on the vertical flange (FIXED) ---
    // Correction: The original model had the countersink on the inner face.
    // The countersink must be on the outer face (the plane at y=0).
    for (x_pos = hole_pos_x_list) {
        // Move the cutter to the outer face (y=0) and rotate it to point inwards (+Y).
        translate([x_pos, 0, hole_pos_z])
        rotate(a=[-90, 0, 0]) {
            countersink_cutter(length = thickness);
        }
    }
}