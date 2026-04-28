// L-Bracket
// Inner corner at origin
// Horizontal flange extends in +Y direction
// Vertical flange extends in +Z direction

// Parameters
width        = 50;   // X direction
h_depth      = 40;   // Horizontal flange depth (Y direction)
v_height     = 40;   // Vertical flange height (Z direction)
thickness    = 3;    // Plate thickness

// Countersunk hole parameters
through_d    = 4.5;  // Through hole diameter (M4)
cs_d         = 8.0;  // Countersink diameter
cs_depth     = 2.0;  // Countersink depth
edge_offset  = 10;   // Distance from edge to hole center
lr_offset    = 15;   // Distance from center-line to each hole (left/right)

module countersunk_hole(depth, from_top=true) {
    // Cylindrical through hole + countersink cone
    // Hole axis along Z; countersink at +Z face when from_top=true
    union() {
        // Through hole
        cylinder(d=through_d, h=depth, center=false, $fn=32);
        if (from_top) {
            // Countersink at top face (z = depth)
            translate([0, 0, depth - cs_depth])
                cylinder(d1=through_d, d2=cs_d, h=cs_depth, $fn=32);
        } else {
            // Countersink at bottom face (z = 0)
            cylinder(d1=cs_d, d2=through_d, h=cs_depth, $fn=32);
        }
    }
}

difference() {
    union() {
        // Horizontal flange: lies on XY plane, extends in +Y
        // Z from -thickness to 0  →  but inner corner is at origin,
        // so horizontal plate occupies Z = [-thickness, 0], Y = [0, h_depth]
        translate([0, 0, -thickness])
            cube([width, h_depth, thickness]);

        // Vertical flange: stands in XZ plane, extends in +Z
        // Y from -thickness to 0, Z = [0, v_height]
        translate([0, -thickness, 0])
            cube([width, thickness, v_height]);
    }

    // --- Countersunk holes in HORIZONTAL flange ---
    // Bolt heads on top (outside = +Z face at z=0), so countersink at top.
    // Holes located at Y = h_depth - edge_offset (10 mm from far edge)
    // X positions: width/2 ± lr_offset
    for (xpos = [width/2 - lr_offset, width/2 + lr_offset]) {
        translate([xpos, h_depth - edge_offset, -thickness])
            // from_top=false → countersink at bottom (z=0 of the shifted solid = z=-thickness global)
            // Actually we want countersink on the OUTER (top) face which is z=0 global.
            // Hole goes from z=-thickness upward, countersink at the top (z=0 global).
            countersunk_hole(thickness, from_top=true);
    }

    // --- Countersunk holes in VERTICAL flange ---
    // Bolt heads on outer face (outside = -Y face at y=-thickness).
    // Holes located at Z = v_height - edge_offset (10 mm from top edge)
    // X positions: width/2 ± lr_offset
    // We'll rotate the hole so its axis is along Y.
    for (xpos = [width/2 - lr_offset, width/2 + lr_offset]) {
        translate([xpos, -thickness, v_height - edge_offset])
            rotate([-90, 0, 0])
                // Hole travels in +Y from y=-thickness to y=0
                // Countersink at top of hole cylinder = outer face (y=-thickness side)
                // from_top=false puts countersink at z=0 of local system = y=-thickness global
                countersunk_hole(thickness, from_top=false);
    }
}