$fn = 96;

// Parameters
leaf_len = 30;
leaf_w   = 25;
leaf_th  = 2;

pin_d = 4;
pin_len = 32;

knuckle_od = 8;
knuckle_id = 4.6;
knuckle_len = 6;

leaf_hole_y = [-8, 0, 8];   // 8 mm pitch

// Layout
// Opened state (180°): both leaf flats lie on the same plane.
// Left leaf extends toward -X, right leaf toward +X.
// Pin axis is aligned with +Y at X=0.
left_leaf_center_x  = -(leaf_w/2 + pin_len/2);
right_leaf_center_x =  (leaf_w/2 + pin_len/2);

// Knuckle centers along Y: 5 equal sections over 30mm => 6mm each.
// Interleaving pattern: left leaf = 3 knuckles, right leaf = 2 knuckles.
left_knuckle_y  = [-9, 0, 9];
right_knuckle_y = [-4.5, 4.5];

module leaf_plate(side=1) {
    // side: -1 left, +1 right
    translate([side * (leaf_w/2 + pin_len/2), 0, 0])
        cube([leaf_w, leaf_len, leaf_th], center=true);
}

module knuckle_segment(yc) {
    translate([0, yc, 0])
    difference() {
        cylinder(d=knuckle_od, h=knuckle_len, center=true);
        cylinder(d=knuckle_id, h=knuckle_len + 2, center=true);
    }
}

module pin_axis() {
    // 1mm protrusion at both ends of the 30mm knuckle span => 32mm total
    cylinder(d=pin_d, h=pin_len, center=true);
}

module leaf_holes(side=1) {
    // Holes are on the side away from knuckles:
    // left leaf outer side = negative X, right leaf outer side = positive X
    x_hole = side * (pin_len/2 + leaf_w - 6);

    for (yy = leaf_hole_y) {
        translate([x_hole, yy, 0]) {
            // Through hole
            translate([0, 0, -leaf_th/2 - 0.2])
                cylinder(d=m3_through_d, h=leaf_th + 0.4);

            // Countersink from the outer surface:
            // top diameter 6mm, depth 1mm, taper to 3.2mm hole
            translate([0, 0, leaf_th/2 - m3_csk_depth])
                cylinder(d1=m3_csk_top_d, d2=m3_through_d, h=m3_csk_depth);
        }
    }
}

module leaf_with_knuckles(side=1) {
    // side: -1 left leaf, +1 right leaf
    difference() {
        union() {
            leaf_plate(side);

            if (side < 0) {
                for (yy = left_knuckle_y)
                    knuckle_segment(yy);
            } else {
                for (yy = right_knuckle_y)
                    knuckle_segment(yy);
            }
        }
        leaf_holes(side);
    }
}

union() {
    // Left leaf
    leaf_with_knuckles(-1);

    // Right leaf
    leaf_with_knuckles(+1);

    // Pin axis centered on the hinge line
    pin_axis();
}