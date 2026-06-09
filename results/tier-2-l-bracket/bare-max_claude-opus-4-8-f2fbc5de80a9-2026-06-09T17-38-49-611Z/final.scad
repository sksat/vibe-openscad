// L-Bracket with countersunk holes for M4 screws
// Internal corner at origin
// Horizontal flange extends in +Y direction
// Vertical flange extends in +Z direction

$fn = 64;

// ---- Parameters ----
flange_width    = 50;   // X width of both flanges
flange_length   = 40;   // Y depth of horizontal / Z height of vertical
thickness       = 3;    // plate thickness

// M4 countersunk hole parameters
hole_dia        = 4.5;  // through hole diameter
csk_dia         = 8;    // countersink (head seat) diameter
csk_depth       = 2;    // countersink depth

// Hole placement
edge_offset     = 10;   // distance from outer edge to hole center
hole_spacing_x  = 30;   // left-right symmetric spacing along X

// ---- Countersunk hole tool ----
// Bore axis along +Z, csk seat opens toward -Z (outer side).
// Tool is centered at origin in XY, top at z=0.
module countersink_tool(len = 50) {
    union() {
        // through hole
        translate([0, 0, -len/2])
            cylinder(h = len, d = hole_dia, center = true);
        // counterbore / countersink seat opening downward (outer side)
        translate([0, 0, -csk_depth])
            cylinder(h = csk_depth + 0.01, d = csk_dia);
    }
}

// ---- Bracket body ----
module l_bracket() {
    union() {
        // Horizontal flange: footprint X[0..width], Y[0..length], Z[0..thickness]
        cube([flange_width, flange_length, thickness]);

        // Vertical flange: footprint X[0..width], Y[0..thickness], Z[0..length]
        cube([flange_width, thickness, flange_length]);
    }
}

// ---- Assembly ----
difference() {
    l_bracket();

    // --- Holes in horizontal flange ---
    // Outer surface is +Z (top). Bore along -Z, csk seat opens toward +Z.
    // Center line at X = flange_width/2, holes at Y = edge_offset from +Y edge.
    for (dx = [-hole_spacing_x/2, hole_spacing_x/2]) {
        translate([flange_width/2 + dx, flange_length - edge_offset, thickness])
            countersink_tool();
    }

    // --- Holes in vertical flange ---
    // Outer surface is +Y (front). Bore along -Y, csk seat opens toward +Y.
    // Rotate tool so its bore axis points along -Y.
    for (dx = [-hole_spacing_x/2, hole_spacing_x/2]) {
        translate([flange_width/2 + dx, thickness, flange_length - edge_offset])
            rotate([-90, 0, 0])
                countersink_tool();
    }
}