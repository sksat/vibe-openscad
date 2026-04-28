// L-bracket (M4 countersunk holes)
$fn = 64;

module countersunk_hole_through(shaft_d=4.5, head_d=8, head_depth=2, through=100) {
    // Countersink (cone frustum) for head seat
    cylinder(h=head_depth, d1=head_d*0.9, d2=shaft_d, center=false);
    // Through hole
    translate([0,0,-0.01])
        cylinder(h=through + 0.02, d=shaft_d, center=false);
    // Optional: flat top at head seat (keeps seat crisp)
    translate([0,0,head_depth-0.01])
        cylinder(h=0.02, d=head_d, center=false);
}

module l_bracket() {
    // Dimensions
    w = 50;      // width (X)
    d = 40;      // depth (Y) for horizontal flange, and height (Z) for vertical flange
    t = 3;       // thickness
    corner = 0;  // inner corner at origin

    // Positions for holes: 10mm from outer edge, symmetric.
    // For each flange, X coordinate is centered at w/2, and Y/Z coordinate is measured from outer edge.
    // Outer edge along that flange is at +d (since inner corner at 0).
    hole_x_offsets = [- (w/2 - 10), + (w/2 - 10)]; // left/right along X
    hole_y = d - 10; // from outer edge back toward inner corner for horizontal flange
    hole_z = d - 10; // from outer edge down toward inner corner for vertical flange

    union() {
        // Horizontal flange: +Y direction from inner corner, located at Z in [0, t]
        translate([ -w/2, 0, 0 ])
            cube([w, d, t]);

        // Vertical flange: +Z direction from inner corner, located at Y in [0, t]
        translate([ -w/2, 0, 0 ])
            rotate([0, -90, 0]) // align thickness along Y, height along Z
                cube([t, d, w], center=false);
        // The above construction: cube([t, d, w]) with rotation around Y is awkward;
        // Instead, create explicitly:
        // (Overwritten below; keep first two lines for clarity but final geometry is fixed with explicit model.)
    }
}

// Rebuild explicitly for robustness
module l_bracket_explicit() {
    w = 50;
    d = 40;
    t = 3;

    hole_x_offsets = [- (w/2 - 10), + (w/2 - 10)];
    hole_y = d - 10;
    hole_z = d - 10;

    difference() {
        union() {
            // Horizontal flange (XY plane thickness in Z)
            translate([ -w/2, 0, 0 ])
                cube([w, d, t]);

            // Vertical flange (YZ plane thickness in Y)
            translate([ -w/2, 0, 0 ])
                cube([w, t, d]);
        }

        // Holes in horizontal flange (through in Y? Actually through thickness in Z)
        // Each hole: countersink from outer side => outer side is -Y for horizontal flange? Let's infer:
        // Horizontal flange extends +Y; outer face is at +Y? Bolt head should be on outside of the L bracket.
        // For horizontal flange, bolt head should be on the side facing away from vertical flange: that's +Y (outer).
        // Therefore countersink should face +Y direction; with our hole axis along Z, "facing" is not meaningful.
        // We'll place countersink cone top facing +Z for horizontal? Countersink normal is along Z.
        // Outer side for horizontal flange is +Z (top surface away from base). We'll countersink from +Z.
        for (x = hole_x_offsets) {
            translate([x, hole_y, t - 0.001])
                rotate([180,0,0])
                    countersunk_hole_through(shaft_d=4.5, head_d=8, head_depth=2, through= t + 0.02);

            // Note: above rotate flips countersink to face downward; adjust to ensure countersink on +Z side.
            // We instead explicitly cut with countersink from +Z side:
            translate([x, hole_y, 0])
                countersunk_hole_through(shaft_d=4.5, head_d=8, head_depth=2, through= t + 0.02);
        }

        // Remove duplicate holes? We'll correct by using only one set per flange:
        // To avoid unintended double subtraction, implement properly below by commenting out above duplication.
    }
}

// Correct implementation without duplication
module l_bracket_final() {
    w = 50;
    d = 40;
    t = 3;

    hole_x_offsets = [- (w/2 - 10), + (w/2 - 10)];
    hole_y = d - 10;
    hole_z = d - 10;

    difference() {
        union() {
            // Horizontal flange: +Y, thickness in Z
            translate([ -w/2, 0, 0 ])
                cube([w, d, t]);

            // Vertical flange: +Z, thickness in Y
            translate([ -w/2, 0, 0 ])
                cube([w, t, d]);
        }

        // Horizontal flange holes (axis: Z through thickness)
        // Countersink seat should be on outer side: for horizontal flange, outer is +Z (top).
        // Create countersink cone with flat seat at +Z side.
        for (x = hole_x_offsets) {
            // Cut countersink + through in Z within [0..t]
            translate([x, hole_y, 0])
                // Countersink cone will occupy up to +head_depth from this origin,
                // so place at bottom and cut; but want cone from +Z:
                // Easiest: build a cone pointing downward and cut through.
                // We'll place module and then flip it so the cone points toward -Z (seat at +Z).
                rotate([180,0,0])
                    countersunk_hole_through(shaft_d=4.5, head_d=8, head_depth=2, through=t + 0.02);
        }

        // Vertical flange holes (axis: Y through thickness)
        // Outer side for vertical flange is +X? Actually flange extends +Z, thickness in Y.
        // Outer side should be away from inside corner; for vertical flange, inside face is at Y=0,
        // outer face is at Y=t. Countersink seat should face +Y (bolt head side).
        for (x = hole_x_offsets) {
            // Holes located on centerline: along X, and at height hole_z from outer edge at +Z
            translate([x, 0, hole_z])
                rotate([0,90,0]) // make hole axis along +Y (since default axis is Z)
                    countersunk_hole_through(shaft_d=4.5, head_d=8, head_depth=2, through=t + 0.02);
        }
    }
}

l_bracket_final();