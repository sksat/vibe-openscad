$fn = 64;

// Dimensions
leaf_len = 30;          // along Y
leaf_w   = 25;          // along X
leaf_t   = 2;           // along Z

pin_d    = 4;
pin_r    = pin_d/2;
pin_len  = 32;          // 1mm protrusion each side beyond 30mm knuckle span

knuckle_od = 8;
knuckle_r  = knuckle_od/2;
knuckle_id  = 4.6;
knuckle_ir  = knuckle_id/2;
knuckle_seg = 6;        // 30 / 5

// Countersunk holes (M3)
hole_d   = 3.2;
hole_r   = hole_d/2;
cs_d     = 6;
cs_r     = cs_d/2;
cs_depth = 1;

// Helpers
module pin() {
    translate([0,-1,1])
        cylinder(h=pin_len, r=pin_r, center=false);
}

module knuckle_barrel(yc) {
    translate([0, yc, 1])
        difference() {
            cylinder(h=knuckle_seg, r=knuckle_r, center=true);
            cylinder(h=knuckle_seg + 0.4, r=knuckle_ir, center=true);
        }
}

module leaf_body_left() {
    // Plate spans x = -25..0, y = 0..30, z = 0..2
    difference() {
        union() {
            translate([-leaf_w, 0, 0])
                cube([leaf_w, leaf_len, leaf_t], center=false);

            // Left leaf knuckles: segments 1,3,5
            knuckle_barrel(3);
            knuckle_barrel(15);
            knuckle_barrel(27);
        }

        // M3 countersunk holes, 3 pcs, 8mm pitch along Y
        for (yy = [6, 14, 22]) {
            translate([-leaf_w/2, yy, leaf_t - cs_depth]) {
                cylinder(h=cs_depth + 0.02, r1=cs_r, r2=hole_r, center=false);
                translate([0,0,-0.05])
                    cylinder(h=leaf_t + 0.10, r=hole_r, center=false);
            }
        }
    }
}

module leaf_body_right() {
    // Plate spans x = 0..25, y = 0..30, z = 0..2
    difference() {
        union() {
            translate([0, 0, 0])
                cube([leaf_w, leaf_len, leaf_t], center=false);

            // Right leaf knuckles: segments 2,4
            knuckle_barrel(9);
            knuckle_barrel(21);
        }

        // M3 countersunk holes, 3 pcs, 8mm pitch along Y
        for (yy = [6, 14, 22]) {
            translate([leaf_w/2, yy, leaf_t - cs_depth]) {
                cylinder(h=cs_depth + 0.02, r1=cs_r, r2=hole_r, center=false);
                translate([0,0,-0.05])
                    cylinder(h=leaf_t + 0.10, r=hole_r, center=false);
            }
        }
    }
}

// Assemble open state (180°): both leaves coplanar
union() {
    leaf_body_left();
    leaf_body_right();
    pin();
}