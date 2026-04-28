$fn = 96;

// Dimensions
leaf_len = 30;          // Y direction
leaf_w   = 25;          // X direction
leaf_th  = 2;           // Z thickness

pin_d    = 4;
pin_len  = 32;

knuckle_od = 8;
knuckle_id = 4.6;
knuckle_len = 6;

m3_through_d = 3.2;
m3_csk_top_d  = 6;
m3_csk_depth  = 1;

// Geometry positions
// Open 180°: both leaves lie in the same plane, with leaves extending
// to opposite sides of the hinge axis along X.
left_leaf_x  = -(pin_len/2 + leaf_w/2);
right_leaf_x =  (pin_len/2 + leaf_w/2);

// Knuckles distributed over 30mm in 5 sections of 6mm each.
// Each knuckle is centered in its section.
// Left leaf: outer 2 + center 1 => sections 1,3,5 => y = -12, 0, 12
// Right leaf: middle 2 => sections 2,4 => y = -6, 6
left_knuckle_y  = [-12, 0, 12];
right_knuckle_y = [-6, 6];

// M3 holes: 3 per leaf, along Y at 8mm pitch, placed on the side
// away from the knuckles.
hole_y = [-8, 0, 8];

module leaf_plate(side=1) {
    // side: -1 left, +1 right
    translate([side * (pin_len/2 + leaf_w/2), 0, 0])
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
    // Pin axis is centered on X=0, Z=0 and runs along Y
    rotate([90,0,0])
        cylinder(d=pin_d, h=pin_len, center=true);
}

module countersunk_hole_at(x, y) {
    // Through-hole
    translate([x, y, 0])
        cylinder(d=m3_through_d, h=leaf_th + 0.4, center=true);

    // Countersink from the outer face of the leaf
    // Left leaf outer face is x = left_leaf_x - leaf_w/2
    // Right leaf outer face is x = right_leaf_x + leaf_w/2
}

module leaf_with_knuckles(side=1) {
    // side: -1 left leaf, +1 right leaf
    holes_x = side < 0 ? (left_leaf_x - leaf_w/2 + 0.8) : (right_leaf_x + leaf_w/2 - 0.8);
    csk_dir = side < 0 ? -1 : 1;

    difference() {
        union() {
            // Leaf plate
            translate([side * (pin_len/2 + leaf_w/2), 0, 0])
                cube([leaf_w, leaf_len, leaf_th], center=true);

            // Knuckles
            if (side < 0) {
                for (yy = left_knuckle_y)
                    knuckle_segment(yy);
            } else {
                for (yy = right_knuckle_y)
                    knuckle_segment(yy);
            }
        }

        // M3 through holes + countersinks
        for (yy = hole_y) {
            translate([holes_x, yy, 0]) {
                // through
                cube([0,0,0]); // no-op to keep scope simple

                // Drill through along X
                rotate([0,90,0])
                    cylinder(d=m3_through_d, h=leaf_w + 2, center=true);

                // Countersink from outer face
                translate([csk_dir * (leaf_w/2 - 0.01), 0, 0])
                    rotate([0,90,0])
                        cylinder(d1=m3_csk_top_d, d2=m3_through_d, h=m3_csk_depth, center=false);
            }
        }
    }
}

union() {
    leaf_with_knuckles(-1);
    leaf_with_knuckles(+1);
    pin_axis();
}