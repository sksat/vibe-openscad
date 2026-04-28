// L-bracket with countersunk holes

// Parameters
horizontal_width = 50;  // mm
horizontal_depth = 40;  // mm
vertical_width = 50;    // mm
vertical_height = 40;   // mm
thickness = 3;          // mm

// Hole parameters
hole_diameter = 4.5;    // mm
countersink_diameter = 8;  // mm
countersink_depth = 2;  // mm
hole_offset_from_edge = 10;  // mm from edge

// Countersunk hole - drilled from one side, countersink on the other side
module countersunk_hole_horizontal() {
    // Through hole
    cylinder(h = thickness + 0.2, r = hole_diameter / 2, center = false, $fn = 32);
    
    // Countersink on top (Z+ direction)
    translate([0, 0, thickness - countersink_depth])
        cylinder(h = countersink_depth + 0.1, r = countersink_diameter / 2, center = false, $fn = 32);
}

module countersunk_hole_vertical() {
    // Through hole
    cylinder(h = thickness + 0.2, r = hole_diameter / 2, center = false, $fn = 32);
    
    // Countersink on front (Y- direction)
    translate([0, -countersink_depth, 0])
        cylinder(h = countersink_depth + 0.1, r = countersink_diameter / 2, center = false, $fn = 32);
}

// Main L-bracket shape
module l_bracket() {
    // Horizontal flange (XY plane, at Z=0 to Z=thickness)
    cube([horizontal_width, horizontal_depth, thickness]);
    
    // Vertical flange (XZ plane, at Y=0 to Y=thickness)
    cube([vertical_width, thickness, vertical_height]);
}

// Holes for horizontal flange (top side, countersink facing up +Z)
module horizontal_flange_holes() {
    hole_y = horizontal_depth / 2;
    
    // Left hole
    hole_x_left = hole_offset_from_edge;
    translate([hole_x_left, hole_y, -0.1]) {
        countersunk_hole_horizontal();
    }
    
    // Right hole
    hole_x_right = horizontal_width - hole_offset_from_edge;
    translate([hole_x_right, hole_y, -0.1]) {
        countersunk_hole_horizontal();
    }
}

// Holes for vertical flange (front side, countersink facing outward -Y)
module vertical_flange_holes() {
    hole_x = vertical_width / 2;
    
    // Bottom hole
    hole_z_bottom = hole_offset_from_edge;
    translate([hole_x, -0.1, hole_z_bottom]) {
        rotate([90, 0, 0])
            countersunk_hole_vertical();
    }
    
    // Top hole
    hole_z_top = vertical_height - hole_offset_from_edge;
    translate([hole_x, -0.1, hole_z_top]) {
        rotate([90, 0, 0])
            countersunk_hole_vertical();
    }
}

// Main assembly
difference() {
    l_bracket();
    horizontal_flange_holes();
    vertical_flange_holes();
}