// Small butt hinge (3 parts assembled) in open position (180deg)

$fn = 64;

// ---- Parameters ----
leaf_L = [30, 25, 2];   // [Y length, X opening direction length, thickness]
t = 2;
Ylen = 30;              // vertical along hinge axis
Xspan = 25;             // opening direction length
pin_d = 4;
pin_len = 32;          // total pin length
knuckle_len = 30;      // along Y
knuckle_segments = 5;  // split into 6mm each
seg = knuckle_len/knuckle_segments; // 6mm
clear = 0.3;
bore_d = pin_d + clear; // 4.6mm

kn_outer = 8;          // outer diameter
kn_inner = bore_d;     // inner bore diameter (with clearance)
gap = 0.2;             // small spacing for boolean robustness

// M3 countersunk holes (3 pcs per leaf)
cs_d_top = 6;          // tapered part top diameter
cs_depth = 1;         // depth of countersink
through_d = 3.2;     // through hole diameter
cs_pitch = 8;         // along Y
// 3 holes: at Y = 8, 16, 24 (given 8mm pitch from top)
hole_ys = [8, 16, 24];

// Open position: leaves are coplanar, flat faces share same plane
// Define leaf thickness along Z.
open180 = 1; // just to clarify

// ---- Helper modules ----

// Leaf plate: centered at hinge line.
// Leaves lie in XY plane at z=0 (thickness along Z).
module leaf_side(x_sign=1) {
    // x_sign: -1 for left (x<0), +1 for right (x>0)
    // Flat face: plane z=0; thickness spans z = [-t/2, +t/2]
    translate([x_sign * (Xspan/2), 0, 0])
        cube([Xspan, Ylen, t], center=true);
}

// Knuckle: cylinder with bore, positioned along Y.
// x0 at 0 by definition.
module knuckle(y_pos=0, side_sign=1) {
    // side_sign not needed for geometry; leaves occupy x!=0.
    // Knuckle sits on leaf thickness (center at z=0), axis along X.
    // But pin axis is Y; knuckles should align with pin axis => cylinder axis along Y.
    // Therefore knuckle cylinder axis along Y, positioned at x=0.
    // Outer: dia 8, Inner bore: dia 4.6 along Y.
    difference() {
        // Outer sleeve
        translate([0, y_pos, 0])
            rotate([0,90,0])  // make cylinder axis along Y (default cylinder axis is Z)
                cylinder(d=kn_outer, h=knuckle_len, center=true);

        // Bore along Y
        translate([0, y_pos, 0])
            rotate([0,90,0])
                cylinder(d=kn_inner, h=knuckle_len + 2*gap, center=true);
    }
}

// Countersunk + through hole pair along Z.
// Hole axis along Z; countersink top on +Z face for each leaf.
module m3_countersink(y_pos=0) {
    // Through cylinder (straight)
    translate([0, y_pos, 0])
        rotate([90,0,0])
            cylinder(d=through_d, h=leaf_L[2] + 4*gap, center=true);

    // Countersink cone: taper with top dia 6, depth 1.
    // Cone axis along Z.
    translate([0, y_pos, leaf_L[2]/2 - cs_depth/2]) {
        // Cone frustum: use cylinder with r1,r2, height=cs_depth
        // Top diameter cs_d_top at top face, bottom at depth end diameter = 3.2
        cylinder(h=cs_depth, r1=cs_d_top/2, r2=through_d/2, center=true);
    }
}

// Build one leaf with its knuckles and 3 screw holes.
module leaf_assembly(x_sign=1, knuckle_count=3, kn_positions=[]) {
    union() {
        // Leaf plate
        leaf_side(x_sign);

        // Knuckles: placed at X=0, on both leaves.
        // For x_sign, knuckle lies at leaf's side near x=0 edge.
        // Leaves are centered at +/- Xspan/2, so their edge at x=sign*Xspan/2.
        // knuckle centerline should be at x=0, which is the hinge axis plane.
        // thus knuckle outer surface overlaps leaf thickness; good enough.
        for (y in kn_positions)
            knuckle(y_pos=y, side_sign=x_sign);
    }
}

// Subtract screw holes from each leaf (their center at the leaf far side).
module leaf_with_holes(x_sign=1, kn_positions=[], holes_on_far_side=true) {
    // far side relative to hinge axis: x_sign * Xspan/2
    // Holes are drilled from the far side surface (towards +x for left?).
    // We'll simply place holes centered on leaf thickness; booleans will cut.
    difference() {
        leaf_assembly(x_sign=x_sign, kn_positions=kn_positions);

        // Countersunk + through holes at 3 Y positions
        for (y in hole_ys) {
            // Hole axis along Z. Place at far side surface (x = x_sign*Xspan/2)
            // Use x location at far face center:
            translate([x_sign * (Xspan/2) , y, 0])
                m3_countersink(y_pos=0); // m3_countersink positions at its local y
        }

        // Bore through knuckles in that leaf for the shared pin
        // (to ensure clean assembly)
        for (y in kn_positions) {
            translate([0, y, 0])
                rotate([0,90,0])
                    cylinder(d=kn_inner, h=kn_outer + 4*gap, center=true);
        }
    }
}

// Pin
module pin() {
    // Pin axis along Y centered at Y=0; length 32mm, centered.
    // knuckle sleeves cover Y=0..0 with center at 0.5? We'll center at Y=0.
    // Place pin so it extends equally; cylinder centered at y=0.
    translate([0, 0, 0])
        rotate([90,0,0]) // make cylinder axis along Y
            cylinder(d=pin_d, h=pin_len, center=true);
}

// ---- Placement of knuckles ----
// Total knuckles separated in Y by 6mm across 30mm (5 segments).
// We use centers at Y = -12, -6, 0, 6, 12 (spanning 30mm).
kn_centers = [-12, -6, 0, 6, 12];

// Left: outer 2 + central 1 => [-12, 0, 12]
left_kn = [kn_centers[0], kn_centers[2], kn_centers[4]];
// Right: "middle 2" => [-6, 6]
right_kn = [kn_centers[1], kn_centers[3]];

// ---- Assemble in open position (180deg) ----
// Ensure leaves are coplanar when open: left x<0, right x>0 already.
module butt_hinge_open180() {
    union() {
        // Left leaf
        leaf_with_holes(x_sign=-1, kn_positions=left_kn);

        // Right leaf
        leaf_with_holes(x_sign= 1, kn_positions=right_kn);

        // Shared pin
        pin();
    }
}

butt_hinge_open180();