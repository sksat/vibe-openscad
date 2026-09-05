// ============================================================
//  Small furniture butt hinge (180 deg open)
//  - Left leaf  : x < 0  (3 knuckles: outer 2 + center 1)
//  - Right leaf : x > 0  (2 knuckles: intermediate)
//  - Pin        : along +Y axis, centered on Y axis
// ============================================================

$fn = 96;

// ---------- Parameters ----------
leaf_len    = 30;    // along Y (hinge axis)
leaf_wid    = 25;    // along X (opening direction)
leaf_thk    = 2;     // plate thickness (Z)

pin_dia     = 4;
pin_len     = 32;    // 1 mm proud at each end

knuckle_od  = 8;
pin_clear   = 0.3;
knuckle_id  = pin_dia + pin_clear;   // 4.6

seg         = leaf_len / 5;          // 6 mm per segment
gap         = 0.15;                  // small running clearance between knuckles

// countersunk screw holes (M3)
cs_top_dia  = 6;
cs_depth    = 1;
hole_dia    = 3.2;
hole_pitch  = 8;
hole_inset  = 6;     // distance from outer edge of leaf to hole centers

eps         = 0.01;

// Segment centers along Y : -12, -6, 0, 6, 12
function seg_y(i) = -leaf_len/2 + seg/2 + i*seg;   // i = 0..4

// ============================================================
//  Modules
// ============================================================

// One knuckle (tube) segment centred on Y = yc
module knuckle(yc, h) {
    translate([0, yc, 0])
        rotate([-90, 0, 0])
            difference() {
                cylinder(h = h, d = knuckle_od, center = true);
                cylinder(h = h + 1, d = knuckle_id, center = true);
            }
}

// Countersunk hole, drilled from +Z down through the plate
module cs_hole() {
    union() {
        // through hole
        translate([0, 0, -leaf_thk/2 - eps])
            cylinder(h = leaf_thk + 2*eps, d = hole_dia);
        // conical countersink at top face
        translate([0, 0, leaf_thk/2 - cs_depth])
            cylinder(h = cs_depth + eps, d1 = hole_dia, d2 = cs_top_dia);
    }
}

// Plate body extending in +X from the knuckle axis, blended into knuckle OD
module leaf_plate() {
    // main flat plate from x = knuckle_od/2 ... leaf_wid
    translate([knuckle_od/2 - 0.5, -leaf_len/2, -leaf_thk/2])
        cube([leaf_wid - knuckle_od/2 + 0.5, leaf_len, leaf_thk]);
}

// Web that ties the plate to its own knuckle segments
module leaf_web(yc, h) {
    translate([0, yc - h/2, -leaf_thk/2])
        cube([knuckle_od/2, h, leaf_thk]);
}

// Screw hole pattern for one leaf (in local +X leaf coordinates)
module leaf_holes() {
    for (k = [-1, 0, 1])
        translate([leaf_wid - hole_inset, k * hole_pitch, 0])
            cs_hole();
}

// ---- Right leaf : plate in +X, knuckles at segments 1 and 3 ----
module right_leaf() {
    color("Silver")
    difference() {
        union() {
            leaf_plate();
            for (i = [1, 3]) {
                knuckle(seg_y(i), seg - gap);
                leaf_web(seg_y(i), seg - gap);
            }
        }
        leaf_holes();
        // clear the pin bore through everything
        rotate([-90, 0, 0])
            cylinder(h = leaf_len + 20, d = knuckle_id, center = true);
    }
}

// ---- Left leaf : mirrored, knuckles at segments 0, 2 and 4 ----
module left_leaf() {
    color("Silver")
    mirror([1, 0, 0])
    difference() {
        union() {
            leaf_plate();
            for (i = [0, 2, 4]) {
                knuckle(seg_y(i), seg - gap);
                leaf_web(seg_y(i), seg - gap);
            }
        }
        leaf_holes();
        rotate([-90, 0, 0])
            cylinder(h = leaf_len + 20, d = knuckle_id, center = true);
    }
}

// ---- Pin ----
module pin() {
    color("DimGray")
    rotate([-90, 0, 0])
        union() {
            cylinder(h = pin_len, d = pin_dia, center = true);
            // small chamfered heads at both ends
            translate([0, 0,  pin_len/2 - 0.4])
                cylinder(h = 0.4, d1 = pin_dia, d2 = pin_dia - 0.8);
            translate([0, 0, -pin_len/2])
                cylinder(h = 0.4, d1 = pin_dia - 0.8, d2 = pin_dia);
        }
}

// ============================================================
//  Assembly : 180 deg open
// ============================================================
left_leaf();
right_leaf();
pin();