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
holes_spacing = 20;     // mm between holes

// Main L-bracket shape
module l_bracket() {
    // Horizontal flange (XY plane, at Z=0)
    cube([horizontal_width, horizontal_depth, thickness]);
    
    // Vertical flange (XZ plane, at Y=0)
    cube([vertical_width, thickness, vertical_height]);
}

// Countersunk hole
module countersunk_hole(depth = 50) {
    // Through hole
    cylinder(h = depth, r = hole_diameter / 2, center = false, $fn = 32);
    
    // Countersink
    cylinder(h = countersink_depth, r = countersink_diameter / 2, center = false, $fn = 32);
}

// Holes for horizontal flange (top side, Z direction)
module horizontal_flange_holes() {
    // Holes positioned on the centerline (Y = horizontal_depth/2)
    // Two holes symmetrically placed
    hole_y = horizontal_depth / 2;
    
    // Left hole
    hole_x_left = hole_offset_from_edge;
    translate([hole_x_left, hole_y, thickness]) {
        rotate([180, 0, 0]) {
            countersunk_hole();
        }
    }
    
    // Right hole
    hole_x_right = horizontal_width - hole_offset_from_edge;
    translate([hole_x_right, hole_y, thickness]) {
        rotate([180, 0, 0]) {
            countersunk_hole();
        }
    }
}

// Holes for vertical flange (front side, Y direction)
module vertical_flange_holes() {
    // Holes positioned on the centerline (X = vertical_width/2)
    // Two holes symmetrically placed
    hole_x = vertical_width / 2;
    
    // Bottom hole
    hole_z_bottom = hole_offset_from_edge;
    translate([hole_x, 0, hole_z_bottom]) {
        rotate([-90, 0, 0]) {
            countersunk_hole();
        }
    }
    
    // Top hole
    hole_z_top = vertical_height - hole_offset_from_edge;
    translate([hole_x, 0, hole_z_top]) {
        rotate([-90, 0, 0]) {
            countersunk_hole();
        }
    }
}

// Main assembly
difference() {
    l_bracket();
    horizontal_flange_holes();
    vertical_flange_holes();
}