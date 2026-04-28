// L-bracket with 4x M4 countersunk holes (2 per flange)
// Inner corner at origin: horizontal flange extends +Y, vertical flange extends +Z

$fn = 64;

module countersunk_hole(
    shaft_d = 4.5,     // through hole Ø
    head_d  = 8,       // countersink seat Ø
    head_h  = 2,       // countersink depth
    through  = 200     // long enough for bores
){
    // Cut sequence along +Z axis (default cylinder axis)
    // Countersink seat (flat at top): place cone so its top is at z=0
    // Then drill through.
    union() {
        // through hole
        translate([0,0,-0.01])
            cylinder(h = through + 0.02, d = shaft_d, center = false);

        // countersink: cone with top at z=0, going to -head_h
        // Use d1 (top) = head_d, d2 (bottom) ~ shaft_d
        translate([0,0,0])
            cylinder(h = head_h, d1 = head_d, d2 = shaft_d, center = false);
    }
}

module l_bracket() {
    w = 50;      // width (X)
    d = 40;      // depth/height along +Y for horizontal, +Z for vertical
    t = 3;       // thickness for both flanges

    // hole positions:
    // "面の中心線上で、面の縁から 10mm 内側、左右対称に2個"
    // For each flange: X is centered -> holes at x = ±(w/2 - 10)
    // For horizontal flange: distance from outer edge (+Y) inward -> y = (d - 10)
    // For vertical flange: distance from outer edge (+Z) inward -> z = (d - 10)
    hx = [-(w/2 - 10), +(w/2 - 10)];
    hy = d - 10;
    hz = d - 10;

    difference() {
        union() {
            // Horizontal flange: size w (X) x d (Y) x t (Z), Z in [0, t]
            translate([-w/2, 0, 0])
                cube([w, d, t]);

            // Vertical flange: size w (X) x t (Y thickness) x d (Z), Y in [0, t], Z in [0, d]
            translate([-w/2, 0, 0])
                cube([w, t, d]);
        }

        // --- Horizontal flange holes ---
        // Outer side for bolt head: outside face at +Z (top of horizontal flange)
        // Therefore countersink should face +Z.
        // Hole axis: Z (through thickness in Z)
        for (x = hx) {
            translate([x, hy, 0])  // start at bottom of flange
                rotate([180,0,0])  // make countersink face +Z (top at +Z)
                    countersunk_hole(shaft_d=4.5, head_d=8, head_h=2, through=t + 20);
        }

        // --- Vertical flange holes ---
        // Outer side for bolt head: outside face at +Y (away from inside corner)
        // Hole axis: Y through thickness t.
        // Build in Y: map default Z-axis model to Y-axis.
        for (x = hx) {
            translate([x, t, hz])   // place at outer face +Y, z=hz
                rotate([0,90,0])    // rotate Z-axis hole to Y-axis
                    // Also flip so countersink seat opens toward +Y (outer side)
                    rotate([180,0,0])
                        countersunk_hole(shaft_d=4.5, head_d=8, head_h=2, through=t + 20);
        }
    }
}

l_bracket();