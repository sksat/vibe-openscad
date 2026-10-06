// Butt Hinge - 3 parts: left leaf, right leaf, pin
// 180° open position

$fn = 64;

// === Parameters ===
leaf_w      = 25;    // width (X direction, away from hinge)
leaf_h      = 30;    // height (Y direction, along pin axis)
leaf_t      = 2;     // thickness (Z direction)

pin_d       = 4;     // pin diameter
pin_len     = 32;    // pin length
pin_clear   = 0.3;   // clearance around pin

knuckle_od  = 8;     // knuckle outer diameter
knuckle_id  = pin_d + 2 * pin_clear; // 4.6 mm bore

num_segments = 5;
seg_len     = leaf_h / num_segments; // 6 mm each

// Countersink parameters
cs_d_top    = 6;     // countersink top diameter
cs_depth    = 1;     // countersink depth
cs_d_bot    = 3.2;   // through-hole diameter
hole_pitch  = 8;     // spacing along Y
hole_x_off  = leaf_w / 2 + knuckle_od / 2; // centre of hole row from X=0

// === Modules ===

// Single knuckle segment (centred at origin, along Y)
module knuckle_solid(len) {
    rotate([-90, 0, 0])
        cylinder(h = len, d = knuckle_od);
}

module knuckle_bore(len) {
    rotate([-90, 0, 0])
        cylinder(h = len + 0.1, d = knuckle_id);
}

// Countersunk hole (drilled in +Z then -Z, centred at origin)
// Plate top face at z = leaf_t/2, bottom at z = -leaf_t/2
module countersunk_hole() {
    // Through hole
    cylinder(h = leaf_t + 2, d = cs_d_bot, center = true);
    // Countersink cone on +Z face (surface mount side)
    translate([0, 0, leaf_t / 2 - cs_depth])
        cylinder(h = cs_depth + 0.01, d1 = cs_d_bot, d2 = cs_d_top);
}

// Row of 3 countersunk holes along Y, offset in X
module hole_row(x_sign) {
    x_pos = x_sign * hole_x_off;
    for (i = [-1, 0, 1]) {
        translate([x_pos, leaf_h / 2 + i * hole_pitch, 0])
            countersunk_hole();
    }
}

// --- Left Leaf (x < 0 side) ---
// Knuckle segments: indices 0, 2, 4  (3 pieces)
module left_leaf() {
    difference() {
        union() {
            // Plate: extends in -X from knuckle centre
            translate([-(leaf_w + knuckle_od / 2), 0, -leaf_t / 2])
                cube([leaf_w, leaf_h, leaf_t]);

            // Knuckles at segments 0, 2, 4
            for (seg = [0, 2, 4]) {
                translate([0, seg * seg_len, 0])
                    knuckle_solid(seg_len);
            }
        }
        // Bore through all knuckles
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(h = leaf_h + 2, d = knuckle_id);

        // Countersunk holes
        hole_row(-1);
    }
}

// --- Right Leaf (x > 0 side) ---
// Knuckle segments: indices 1, 3  (2 pieces)
module right_leaf() {
    difference() {
        union() {
            // Plate: extends in +X from knuckle centre
            translate([knuckle_od / 2, 0, -leaf_t / 2])
                cube([leaf_w, leaf_h, leaf_t]);

            // Knuckles at segments 1, 3
            for (seg = [1, 3]) {
                translate([0, seg * seg_len, 0])
                    knuckle_solid(seg_len);
            }
        }
        // Bore through all knuckles
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(h = leaf_h + 2, d = knuckle_id);

        // Countersunk holes
        hole_row(1);
    }
}

// --- Pin ---
module pin() {
    translate([0, -1, 0])   // 1 mm protrusion below
        rotate([-90, 0, 0])
            cylinder(h = pin_len, d = pin_d);
}

// === Assembly (180° open) ===
// Both leaves flat in XY plane, top faces at z = leaf_t/2

color("SteelBlue")  left_leaf();
color("SteelBlue")  right_leaf();
color("Silver")     pin();