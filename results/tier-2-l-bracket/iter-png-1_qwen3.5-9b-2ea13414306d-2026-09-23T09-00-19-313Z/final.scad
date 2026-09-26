module lbracket() {
  // L-Bracket Dimensions
  width = 50;    // X axis
  depth_h = 40;  // Y axis (Horizontal)
  height_v = 40; // Z axis (Vertical)
  thickness = 3; // mm
  
  union() {
    // Horizontal Flange
    translate([0, 0, 0])
      cube([width, depth_h, thickness]);
    
    // Vertical Flange
    translate([0, 0, 0])
      cube([width, thickness, height_v]);
  }
  
  // Remove holes
  difference() {
    // Re-extract shape for hole positioning
    union() {
      translate([0, 0, 0])
        cube([width, depth_h, thickness]);
      translate([0, 0, 0])
        cube([width, thickness, height_v]);
    }
    
    // Hole parameters
    d_through = 4.5;
    d_counter = 8;
    h_counter = 2;
    
    // Horizontal Flange Holes
    for (y = [10, 30]) {
      translate([25, y, 0]) {
        // Counterbore on outer side (Z positive face)
        translate([0, 0, 1])
          cylinder(d = d_counter, h = h_counter, $fn=64);
        // Through Hole
        translate([0, 0, 0])
          cylinder(d = d_through, h = thickness, $fn=64);
      }
    }
    
    // Vertical Flange Holes
    for (z = [10, 30]) {
      translate([25, 0, z]) {
        // Counterbore on outer side (Y positive face)
        translate([0, 1, 0])
          cylinder(d = d_counter, h = h_counter, $fn=64);
        // Through Hole
        translate([0, 0, 0])
          cylinder(d = d_through, h = thickness, $fn=64);
      }
    }
  }
}

// Main - call module at top level
lbracket();