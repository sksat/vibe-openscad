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

// Module for countersunk hole (pointing in -Z direction, countersink on top)
module countersunk_hole() {
    union() {
        // Through hole
        cylinder(h = thickness + 1, d = hole_diameter, center = true, $fn = 32);
        // Countersink (cone + cylinder for flat bottom)
        translate([0, 0, thickness/2 - countersink_depth/2 + 0.01])
            cylinder(h = countersink_depth + 0.01, d1 = hole_diameter, d2 = countersink_diameter, $fn = 32);
    }
}

// Hole positions on horizontal flange (Y-Z plane holes, on surface facing -Z)
hole_x_offset = flange_width / 2;  // Center line
hole_y_positions = [edge_distance, flange_depth - edge_distance];

// Hole positions on vertical flange
hole_z_positions = [edge_distance, flange_depth - edge_distance];

difference() {
    union() {
        // Horizontal flange (+Y direction, sitting on Z=0 plane going down in -Z)
        // Actually: horizontal flange extends in +Y, thickness goes in -Z direction
        translate([0, 0, -thickness])
            cube([flange_width, flange_depth, thickness]);
        
        // Vertical flange (+Z direction)
        translate([0, -thickness, 0])
            cube([flange_width, thickness, flange_depth]);
    }
    
    // Countersunk holes on horizontal flange (countersink on bottom, -Z side)
    for (y = hole_y_positions) {
        translate([hole_x_offset, y, -thickness/2])
            rotate([180, 0, 0])
                countersunk_hole();
    }
    
    // Countersunk holes on vertical flange (countersink on -Y side, outside)
    for (z = hole_z_positions) {
        translate([hole_x_offset, -thickness/2, z])
            rotate([90, 0, 0])
                countersunk_hole();
    }
}