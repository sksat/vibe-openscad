// Small butt hinge - 180° open state
// Pin axis along Y, leaves on Z=0 plane (180° open)
// Left leaf: x<0, knuckles at segments 0,2,4 (outer + middle)
// Right leaf: x>0, knuckles at segments 1,3 (between)

$fn = 64;

// ---- Parameters ----
leaf_w_total = 25;   // total leaf width including knuckle radius
leaf_h       = 30;   // leaf height (along Y, hinge axis)
leaf_t       = 2;    // leaf thickness
knuckle_od   = 8;    // knuckle outer diameter
knuckle_id   = 4.6;  // knuckle inner diameter (pin 4 + 0.6 clearance)
pin_d        = 4;    // pin diameter
pin_len      = 32;   // pin length (1mm overhang each end)
seg          = 6;    // segment length (30 / 5)

// Flat plate width (excluding the part occupied by knuckle radius)
plate_w = leaf_w_total - knuckle_od/2;

// Screw hole parameters
screw_through_d = 3.2;
screw_csk_d     = 6;
screw_csk_depth = 1;
screw_pitch     = 8;

// ---------- Leaf with knuckles ----------
module leaf(side="left") {
    sign = (side=="left") ? -1 : 1;
    knuckle_segs = (side=="left") ? [0,2,4] : [1,3];

    difference() {
        union() {
            // Flat plate: inner edge tangent to knuckle outer cylinder
            if (side=="left") {
                translate([-knuckle_od/2 - plate_w, 0, -leaf_t/2])
                    cube([plate_w, leaf_h, leaf_t]);
            } else {
                translate([knuckle_od/2, 0, -leaf_t/2])
                    cube([plate_w, leaf_h, leaf_t]);
            }

            // Knuckles (cylinders) for this leaf
            for (i = knuckle_segs) {
                translate([0, i*seg, 0])
                    rotate([-90, 0, 0])
                        cylinder(d=knuckle_od, h=seg);
            }

            // Web connecting plate to knuckle (so plate flush-merges with knuckle wall)
            for (i = knuckle_segs) {
                if (side=="left")
                    translate([-knuckle_od/2, i*seg, -leaf_t/2])
                        cube([knuckle_od/2, seg, leaf_t]);
                else
                    translate([0, i*seg, -leaf_t/2])
                        cube([knuckle_od/2, seg, leaf_t]);
            }
        }

        // Pin hole through knuckles
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(d=knuckle_id, h=leaf_h + 2);

        // Screw holes (3 along Y), centered on the flat plate
        hole_x = sign * (knuckle_od/2 + plate_w/2);
        y_center = leaf_h/2;
        for (i = [-1, 0, 1]) {
            y = y_center + i*screw_pitch;
            // Through hole
            translate([hole_x, y, -leaf_t/2 - 0.1])
                cylinder(d=screw_through_d, h=leaf_t + 0.2);
            // Countersink on +Z (visible) face
            translate([hole_x, y, leaf_t/2 - screw_csk_depth])
                cylinder(d1=screw_through_d, d2=screw_csk_d,
                         h=screw_csk_depth + 0.01);
        }
    }
}

// ---------- Pin ----------
module pin() {
    translate([0, -1, 0])
        rotate([-90, 0, 0])
            cylinder(d=pin_d, h=pin_len);
}

// ---------- Assembly (180° open) ----------
color("steelblue")  leaf(side="left");
color("slategray")  leaf(side="right");
color("gold")       pin();