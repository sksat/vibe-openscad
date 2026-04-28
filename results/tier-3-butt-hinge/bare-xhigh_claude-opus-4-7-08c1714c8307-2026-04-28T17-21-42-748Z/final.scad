// Small butt hinge - opened 180 degrees
// Pin axis along Y, leaves on Z=0 plane

$fn = 64;

// ---- Parameters ----
leaf_long   = 30;   // along Y (hinge axis)
leaf_wide   = 25;   // along X (away from axis)
leaf_thick  = 2;

pin_dia     = 4;
pin_len     = 32;

knuckle_od  = 8;
knuckle_id  = pin_dia + 0.6;   // 4.6 mm hole
knuckle_seg = 6;               // 30/5

screw_clear = 3.2;
csk_dia     = 6;
csk_depth   = 1;
screw_count = 3;
screw_pitch = 8;

// ---- Knuckle (hollow cylinder) along Y ----
module knuckle(y_start, length) {
    translate([0, y_start, 0])
        rotate([-90, 0, 0])
            difference() {
                cylinder(h = length, d = knuckle_od);
                translate([0, 0, -0.1])
                    cylinder(h = length + 0.2, d = knuckle_id);
            }
}

// ---- Leaf plate with countersunk holes ----
// Plate extends from x = x_inner to x = x_inner + sign*leaf_wide
// The plate's inner edge (near knuckle) is tangent to knuckle OD
module leaf_plate(direction = 1) {
    // direction = -1 (left) or +1 (right)
    inner_x = direction * (knuckle_od / 2);
    outer_x = inner_x + direction * leaf_wide;
    x_min = min(inner_x, outer_x);

    difference() {
        // Plate: top face at z=0, bottom at z=-leaf_thick
        translate([x_min, -leaf_long/2, -leaf_thick])
            cube([leaf_wide, leaf_long, leaf_thick]);

        // Screw holes - centered along plate width, on far side from knuckle
        // Position screws roughly at 2/3 from knuckle (away from knuckle)
        screw_x = inner_x + direction * (leaf_wide * 0.65);

        for (i = [0 : screw_count - 1]) {
            y = -((screw_count - 1) * screw_pitch) / 2 + i * screw_pitch;

            // Through hole
            translate([screw_x, y, -leaf_thick - 0.1])
                cylinder(h = leaf_thick + 0.2, d = screw_clear);

            // Countersink (taper) - opens upward (top surface at z=0)
            translate([screw_x, y, -csk_depth])
                cylinder(h = csk_depth + 0.01,
                         d1 = screw_clear, d2 = csk_dia);
        }
    }
}

// ---- Left leaf: knuckles at outer (0..6, 24..30) and center (12..18) ----
module left_leaf() {
    color("silver") {
        leaf_plate(-1);
        // Knuckle Y positions (relative to leaf center at y=0):
        // segments: [-15,-9], [-9,-3], [-3,3], [3,9], [9,15]
        knuckle(-15, knuckle_seg);   // outer
        knuckle(-3,  knuckle_seg);   // center
        knuckle(9,   knuckle_seg);   // outer
    }
}

// ---- Right leaf: knuckles in intermediate positions (6..12, 18..24) ----
module right_leaf() {
    color("gainsboro") {
        leaf_plate(1);
        knuckle(-9, knuckle_seg);
        knuckle(3,  knuckle_seg);
    }
}

// ---- Pin ----
module pin() {
    color("dimgray")
        translate([0, -pin_len/2, 0])
            rotate([-90, 0, 0])
                cylinder(h = pin_len, d = pin_dia);
}

// ---- Assembly (180° open) ----
left_leaf();
right_leaf();
pin();