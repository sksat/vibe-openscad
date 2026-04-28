// L-bracket with 4x M4 countersunk holes (2 per flange)
// Inner corner at origin: horizontal flange extends +Y, vertical flange extends +Z

$fn = 96;

module countersunk_hole(shaft_d=4.5, head_d=8, head_h=2, through=100)
{
    // Cut with axis along +Z (top at z=0, extends to -Z)
    union() {
        cylinder(h=through, d=shaft_d, center=false);                       // through hole
        cylinder(h=head_h,  d1=head_d, d2=shaft_d, center=false);          // countersink
    }
}

module l_bracket()
{
    w = 50;   // X size
    d = 40;   // Y (horizontal) / Z (vertical) size
    t = 3;    // thickness of both flanges

    // Hole centers along X on the centerline; 10mm from outer edges.
    // Outer edges at x=±w/2 => center positions at x=±(w/2 - 10)
    hx = [-(w/2 - 10), (w/2 - 10)];

    // Hole center lines 10mm inside from outer edge.
    // Horizontal flange outer edge at Y=d => hole centers at y=d-10
    // Vertical flange outer edge at Z=d => hole centers at z=d-10
    hy = d - 10;
    hz = d - 10;

    difference() {
        union() {
            // Horizontal flange: X[-w/2..+w/2], Y[0..d], Z[0..t]
            translate([-w/2, 0, 0])
                cube([w, d, t]);

            // Vertical flange: X[-w/2..+w/2], Y[0..t], Z[0..d]
            translate([-w/2, 0, 0])
                cube([w, t, d]);
        }

        // --- Horizontal flange holes (2x) ---
        // Countersink should face the outer side: +Z face (top of horizontal flange).
        // We cut by placing hole primitive at z=t and cutting downward (-Z).
        for (x = hx) {
            translate([x, hy, t])
                // hole axis along -Z: already built as cutting from z=0 downwards,
                // so just translate; no flips needed.
                countersunk_hole(shaft_d=4.5, head_d=8, head_h=2, through=100);
        }

        // --- Vertical flange holes (2x) ---
        // Countersink should face outer side: +Y face of the vertical flange (away from inner corner).
        // Place at y=t and cut toward -Y (i.e., axis along -Y).
        for (x = hx) {
            translate([x, t, hz])
                rotate([0, 90, 0])   // rotate Z-axis hole to Y-axis
                    // now the countersink axis direction should be toward -Y.
                    // The countersunk_hole is built to extend along -Z from its local origin.
                    // After rotation, that becomes extension along -Y.
                    countersunk_hole(shaft_d=4.5, head_d=8, head_h=2, through=100);
        }
    }
}

l_bracket();