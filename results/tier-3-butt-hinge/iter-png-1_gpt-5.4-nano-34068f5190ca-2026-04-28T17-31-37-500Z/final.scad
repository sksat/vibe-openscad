// Small butt hinge (3 parts assembled) in open position (180deg)

$fn = 96;

// ---- Parameters ----
t = 2;                 // leaf thickness (Z)
Ylen = 30;             // leaf length along hinge axis (Y)
Xspan = 25;            // leaf length along opening direction (X)
pin_d = 4;
pin_len = 32;         // total pin length

knuckle_len = 30;     // along Y
knuckle_segments = 5; // split into 6mm each (=> 6mm)
seg = knuckle_len/knuckle_segments; // 6mm

clear = 0.3;
bore_d = pin_d + clear; // 4.6mm

kn_outer = 8;
kn_inner = bore_d;

gap = 0.2;            // boolean robustness

// M3 countersunk holes (3 pcs per leaf)
cs_d_top = 6;        // countersink cone top diameter (mm)
cs_depth = 1;        // countersink depth (mm)
through_d = 3.2;    // through hole diameter (mm)
hole_pitch = 8;      // spacing along Y
hole_ys = [8, 16, 24];// based on 8mm pitch

// ---- Helper: make a cylinder whose axis is along Y ----
module cyl_y(d=1, h=1, center=true) {
    rotate([90,0,0]) cylinder(d=d, h=h, center=center);
}

// ---- Leaf plate: centered at hinge axis plane (X=0) ----
// Leaf lies in the XY plane with Z thickness.
module leaf_plate(x_sign=1) {
    // x_sign=-1 => leaf on x<0, x_sign=+1 => leaf on x>0
    translate([x_sign * (Xspan/2), 0, 0])
        cube([Xspan, Ylen, t], center=true);
}

// ---- Knuckle sleeve with bore: sleeve axis along Y ----
// Y position sets the sleeve center.
module knuckle(y_pos=0) {
    difference() {
        // outer sleeve
        translate([0, y_pos, 0]) cyl_y(d=kn_outer, h=knuckle_len, center=true);

        // bore along Y
        translate([0, y_pos, 0]) cyl_y(d=kn_inner, h=knuckle_len + 2*gap, center=true);
    }
}

// Countersunk + through hole (axis along Z), located at a given Y.
// Countersink is on the leaf side corresponding to +Z (we'll subtract; geometry stays correct).
module m3_hole_z() {
    // Through hole
    cylinder(d=through_d, h=t + 4*gap, center=true);

    // Countersink (cone frustum)
    translate([0,0, (cs_depth/2)])  // start at +Z face
        cylinder(h=cs_depth, d1=cs_d_top, d2=through_d, center=true);
}

// Build one leaf including its knuckles and screw holes,
// while also subtracting bore cylinders so shared knuckles align.
module leaf_with_knuckles_and_holes(x_sign=1, kn_positions=[], screw_far_face_sign=1) {
    // screw_far_face_sign: +1 => countersink normal to +Z face doesn't matter much for subtract,
    // we'll model only using "top at +Z" countersink. Since both leaves are at Z=0 plane,
    // subtraction will work regardless of which side is "far"; using +Z countersink is fine.
    difference() {
        union() {
            leaf_plate(x_sign);

            // Add knuckles at X=0 plane (hinge axis plane)
            for (y in kn_positions) knuckle(y);
        }

        // Subtract pin bores through the knuckles that belong to this leaf.
        // (So left and right both have the aligned holes.)
        for (y in kn_positions) {
            translate([0, y, 0]) cyl_y(d=kn_inner, h=kn_outer + 4*gap, center=true);
        }

        // Subtract 3 screw holes.
        // "Each plate side away from knuckle": given only as "far side", which is at x = x_sign*Xspan/2.
        // Use that as center for the hole axis along Z.
        for (yy in hole_ys) {
            translate([x_sign * (Xspan/2), yy, 0]) {
                // Countersink+through. Centered hole modeled along Z.
                // Ensure countersink is cut from the +Z face by positioning the cone appropriately.
                // The m3_hole_z module uses +Z face countersink by default.
                m3_hole_z();
            }
        }
    }
}

// Pin: cylinder along Y, total length 32mm (centered at Y=0).
module pin() {
    cyl_y(d=pin_d, h=pin_len, center=true);
}

// ---- Knuckle placement along Y ----
// Total knuckles separated in Y by 6mm across 30mm (5 segments).
// Centers at Y = -12, -6, 0, 6, 12 spanning 30mm.
kn_centers = [-12, -6, 0, 6, 12];

// Left: outer 2 + central 1 => [-12, 0, 12]
// Right: middle 2 => [-6, 6]
left_kn = [kn_centers[0], kn_centers[2], kn_centers[4]];
right_kn = [kn_centers[1], kn_centers[3]];

// ---- Main assembly in open position (180deg) ----
// Leaves already coplanar at Z=0 and placed on x<0 and x>0.
module butt_hinge_open180() {
    union() {
        // Left leaf
        leaf_with_knuckles_and_holes(x_sign=-1, kn_positions=left_kn);

        // Right leaf
        leaf_with_knuckles_and_holes(x_sign= 1, kn_positions=right_kn);

        // Shared pin
        translate([0, 0, 0]) pin();
    }
}

butt_hinge_open180();