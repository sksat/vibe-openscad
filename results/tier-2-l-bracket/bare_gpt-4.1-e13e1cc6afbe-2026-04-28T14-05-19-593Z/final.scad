// L-bracket parameters
bracket_w = 50;   // width (common to both flanges)
bracket_h = 40;   // height / depth of flanges
thickness = 3;

// Countersunk hole parameters
hole_d = 4.5;      // through hole diameter
cs_d = 8;          // countersink diameter
cs_depth = 2;      // countersink depth
edge_offset = 10;  // distance from edge to hole center (along the main axis)
center_line = bracket_w/2;

// Hole positions (symmetric along width)
hole_y_pos = [edge_offset, bracket_h-edge_offset];

// Utilities
module countersunk_hole(face="") {
    // face: "top" or "side"
    if (face == "top") {
        // Plate at Z = 0, +Y; hole along -Z
        translate([0,0,thickness])
        rotate([90,0,0])
        union() {
            // Through hole
            cylinder(d=hole_d, h=thickness+0.5, $fn=32);
            // Countersink
            translate([0,0,-cs_depth])
            cylinder(d=cs_d, h=cs_depth, $fn=32);
        }
    }
    if (face == "side") {
        // Plate at Y = 0, +Z; hole along -Y
        translate([0,thickness,0])
        rotate([0,90,0])
        union() {
            // Through hole
            cylinder(d=hole_d, h=thickness+0.5, $fn=32);
            // Countersink
            translate([0,0,-cs_depth])
            cylinder(d=cs_d, h=cs_depth, $fn=32);
        }
    }
}

// Horizontal flange
module flange_top() {
    difference() {
        // Main plate
        translate([0, 0, 0])
            cube([bracket_w, bracket_h, thickness]);
        // Holes
        for (ypos = hole_y_pos)
            translate([center_line, ypos, 0])
                countersunk_hole("top");
    }
}

// Vertical flange
module flange_side() {
    difference() {
        // Main plate
        translate([0, 0, 0])
            cube([bracket_w, thickness, bracket_h]);
        // Holes
        for (zpos = hole_y_pos)
            translate([center_line, 0, zpos])
                countersunk_hole("side");
    }
}

// Assemble L-bracket at origin (inner corner at [0,0,0])
flange_top();
flange_side();