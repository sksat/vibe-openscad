// L-Bracket Parameters
bracket_width  = 50;   // Width (X)
bracket_depth  = 40;   // Depth of horizontal flange (Y)
bracket_height = 40;   // Height of vertical flange (Z)
thickness      = 3;    // Plate thickness

// Hole Parameters
hole_dia       = 4.5;   // Thread diameter
counter_dia    = 8;     // Countersink diameter
counter_depth  = 2;     // Depth of countersink
hole_offset    = 10;    // Distance from edge to hole center along flange

// Helper function: create a hole with countersink
module threaded_hole() {
    // Countersink (extruded into the plate)
    cylinder(h=counter_depth, r=counter_dia/2, $fn=30);
    // Thread hole (full depth of the plate)
    translate([0, 0, -thickness]) 
        cylinder(h=thickness + counter_depth, r=hole_dia/2, $fn=30);
}

// Main bracket
module l_bracket() {
    difference() {
        // Horizontal flange (Y direction)
        cube([bracket_width, bracket_depth, thickness]);

        // Vertical flange (Z direction) positioned at the end of horizontal flange
        translate([0, 0, thickness])
            rotate([90, 0, 0])   // Align along Z
                cube([bracket_width, bracket_height, thickness]);
    }
}

// Position holes on each face
module place_holes() {
    // Horizontal face (Y positive)
    for(x = [hole_offset, bracket_width - hole_offset])
        translate([x, 0, thickness/2]) threaded_hole();

    // Vertical face (Z positive)
    for(x = [hole_offset, bracket_width - hole_offset])
        translate([x, 0, thickness + counter_depth + thickness/2]) threaded_hole();
}

// Assemble
l_bracket();
place_holes();