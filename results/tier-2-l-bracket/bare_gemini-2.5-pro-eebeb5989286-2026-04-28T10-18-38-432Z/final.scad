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
//                  Model
// ===============================================
difference() {
    
    // 1. Create the main body of the L-bracket
    // The inner corner is at the origin [0, 0, 0]
    union() {
        // Horizontal flange, extending in +Y direction
        cube([width, depth, thickness]);
        
        // Vertical flange, extending in +Z direction
        cube([width, thickness, height]);
    }
    
    // 2. Create and subtract the countersunk holes
    
    // --- Holes on the horizontal flange ---
    // The countersinks face downwards (towards -Z)
    for (x_pos = hole_pos_x_list) {
        // Position the cutter at the top surface (z=thickness) and rotate it to face down
        translate([x_pos, hole_pos_y, thickness])
        rotate(a=[180, 0, 0]) {
            // A small epsilon for clean subtraction
            eps = 0.1;
            // Countersink cone (frustum)
            cylinder(h = cs_depth, d1 = cs_dia, d2 = hole_dia);
            // Through-hole
            cylinder(h = thickness + eps, d = hole_dia);
        }
    }
    
    // --- Holes on the vertical flange ---
    // The countersinks face forwards (towards -Y)
    for (x_pos = hole_pos_x_list) {
        // Position the cutter at the front surface (y=thickness) and rotate it to face forward
        translate([x_pos, thickness, hole_pos_z])
        rotate(a=[90, 0, 0]) {
            // A small epsilon for clean subtraction
            eps = 0.1;
            // Countersink cone (frustum)
            cylinder(h = cs_depth, d1 = cs_dia, d2 = hole_dia);
            // Through-hole
            cylinder(h = thickness + eps, d = hole_dia);
        }
    }
}