// L-bracket with countersunk holes

// Parameters
flange_width = 50;      // X direction
flange_depth = 40;      // Y direction for horizontal, Z direction for vertical
thickness = 3;

// Countersunk hole parameters
hole_diameter = 4.5;    // M4 through hole
countersink_diameter = 8;
countersink_depth = 2;
edge_distance = 10;     // Distance from edge to hole center

// Module for countersunk hole
module countersunk_hole(h) {
    union() {
        // Through hole
        cylinder(h = h + 1, d = hole_diameter, center = true, $fn = 32);
        // Countersink (cone) at top
        translate([0, 0, h/2 - countersink_depth])
            cylinder(h = countersink_depth + 0.01, d1 = hole_diameter, d2 = countersink_diameter, $fn = 32);
    }
}

// Hole X positions (symmetric about center line, 10mm from left and right edges)
hole_x_positions = [edge_distance, flange_width - edge_distance];

difference() {
    union() {
        // Horizontal flange: inner surface at Z=thickness, outer surface at Z=0
        // Extends in +Y direction from origin
        cube([flange_width, flange_depth, thickness]);
        
        // Vertical flange: inner surface at Y=thickness, outer surface at Y=0
        // Extends in +Z direction from origin
        cube([flange_width, thickness, flange_depth]);
    }
    
    // Countersunk holes on horizontal flange
    // Holes centered at Y = flange_depth - edge_distance (10mm from far edge)
    // Countersink on bottom (Z=0 side, outside where bolt head sits)
    for (x = hole_x_positions) {
        translate([x, flange_depth - edge_distance, thickness/2])
            rotate([180, 0, 0])
                countersunk_hole(thickness);
    }
    
    // Countersunk holes on vertical flange
    // Holes centered at Z = flange_depth - edge_distance (10mm from top edge)
    // Countersink on front (Y=0 side, outside where bolt head sits)
    for (x = hole_x_positions) {
        translate([x, thickness/2, flange_depth - edge_distance])
            rotate([90, 0, 0])
                countersunk_hole(thickness);
    }
}