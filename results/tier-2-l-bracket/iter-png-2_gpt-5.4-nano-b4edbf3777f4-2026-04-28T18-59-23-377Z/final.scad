// L-bracket with 4x M4 countersunk holes (2 per flange)
// Inner corner at origin: horizontal flange extends +Y, vertical flange extends +Z

$fn = 96;

module countersunk_hole(shaft_d=4.5, head_d=8, head_h=2, through=50){
    // Countersink + through: axis along +Z (top at z=0, extends to -)
    // Note: We start hole at z=0 and cut downward so it cleanly matches the faces.
    union() {
        // through
        cylinder(h=through, d=shaft_d, center=false);

        // countersink (cone)
        translate([0,0,0])
            cylinder(h=head_h, d1=head_d, d2=shaft_d, center=false);
    }
}

module l_bracket() {
    w = 50;   // width (X)
    d = 40;   // length of flange along Y (horizontal) / Z (vertical)
    t = 3;    // thickness of both flanges

    // hole x positions: on center line in X, 10mm inside from outer edge -> x = ±(w/2-10)
    hx = [-(w/2 - 10), (w/2 - 10)];

    // hole y/z positions: 10mm inside from outer edge
    hy = d - 10; // for horizontal flange: y in [0..d], outer edge at y=d
    hz = d - 10; // for vertical flange: z in [0..d], outer edge at z=d

    difference() {
        union() {
            // Horizontal flange: X=[-w/2..+w/2], Y=[0..d], Z=[0..t]
            translate([-w/2, 0, 0])
                cube([w, d, t]);

            // Vertical flange: X=[-w/2..+w/2], Y=[0..t], Z=[0..d]
            translate([-w/2, 0, 0])
                cube([w, t, d]);
        }

        // --- Horizontal flange holes (2x) ---
        // Countersink should face outer side: +Z (top face at z=t)
        for (x = hx) {
            // Place so that countersink seat is cut from the top face (z=t) downwards
            translate([x, hy, t])
                rotate([180,0,0]) // flip so the countersink points upward (+Z face) in original model coordinates
                    countersunk_hole(shaft_d=4.5, head_d=8, head_h=2, through=100);
        }

        // --- Vertical flange holes (2x) ---
        // Countersink should face outer side: +Y (away from inner corner)
        // Vertical flange thickness is along Y: Y in [0..t], outer face at Y=t
        for (x = hx) {
            // Place at outer face (y=t) and cut toward -Y
            translate([x, t, hz])
                rotate([0,90,0])   // rotate Z-axis hole to Y-axis
                    // flip to ensure countersink opens toward +Y (outer face)
                    rotate([180,0,0])
                        countersunk_hole(shaft_d=4.5, head_d=8, head_h=2, through=100);
        }
    }
}

l_bracket();