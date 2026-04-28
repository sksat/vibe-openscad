// L-bracket parameters
width = 50;
depth = 40;
height = 40;
thickness = 3;

// Countersunk hole parameters
hole_dia = 4.5;
countersink_dia = 8;
countersink_depth = 2;
hole_offset = 10;

// Main L-bracket
difference() {
    union() {
        // Horizontal flange
        cube([width, depth, thickness]);
        
        // Vertical flange
        cube([width, thickness, height]);
    }
    
    // Horizontal flange holes
    for (x = [hole_offset, width - hole_offset]) {
        translate([x, depth/2, 0]) {
            // Through hole
            cylinder(h = thickness + 0.1, d = hole_dia, $fn = 32);
            // Countersink
            translate([0, 0, thickness - countersink_depth])
                cylinder(h = countersink_depth + 0.1, d1 = hole_dia, d2 = countersink_dia, $fn = 32);
        }
    }
    
    // Vertical flange holes
    for (x = [hole_offset, width - hole_offset]) {
        translate([x, -0.05, height/2]) {
            rotate([-90, 0, 0]) {
                // Through hole
                cylinder(h = thickness + 0.1, d = hole_dia, $fn = 32);
                // Countersink
                translate([0, 0, thickness - countersink_depth])
                    cylinder(h = countersink_depth + 0.1, d1 = hole_dia, d2 = countersink_dia, $fn = 32);
            }
        }
    }
}