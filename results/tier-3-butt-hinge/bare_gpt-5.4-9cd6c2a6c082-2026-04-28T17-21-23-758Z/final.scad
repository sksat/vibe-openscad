$fn = 96;

// ===== Parameters =====
leaf_len = 30;          // along Y
leaf_w   = 25;          // along X from hinge axis outward
leaf_t   = 2;           // along Z

pin_d = 4;
pin_r = pin_d/2;
pin_len = 32;

knuckle_od = 8;
knuckle_or = knuckle_od/2;
knuckle_id = 4.6;
knuckle_ir = knuckle_id/2;
knuckle_seg = 6;        // 30 / 5

csk_through_d = 3.2;
csk_head_d = 6.0;
csk_depth = 1.0;

// screw positions on each leaf
screw_y = [7, 15, 23];

// ===== Helpers =====
module pin_axis() {
    translate([0, -1, 0])
        rotate([-90, 0, 0])
            cylinder(h = pin_len, r = pin_r);
}

module knuckle_segment(y0) {
    translate([0, y0, 0])
        rotate([-90, 0, 0])
            difference() {
                cylinder(h = knuckle_seg, r = knuckle_or);
                cylinder(h = knuckle_seg, r = knuckle_ir);
            }
}

module countersunk_hole(ypos, xfrom_axis, from_top=true) {
    x = xfrom_axis;
    translate([x, ypos, 0]) {
        // through hole
        cylinder(h = leaf_t, d = csk_through_d);
        // countersink from top surface
        if (from_top) {
            translate([0, 0, leaf_t - csk_depth])
                cylinder(h = csk_depth + 0.001, d1 = csk_through_d, d2 = csk_head_d);
        } else {
            cylinder(h = csk_depth + 0.001, d1 = csk_head_d, d2 = csk_through_d);
        }
    }
}

module leaf_base(side="left") {
    if (side == "left") {
        translate([-leaf_w, 0, 0])
            cube([leaf_w, leaf_len, leaf_t]);
    } else {
        translate([0, 0, 0])
            cube([leaf_w, leaf_len, leaf_t]);
    }
}

module left_leaf() {
    difference() {
        union() {
            leaf_base("left");
            knuckle_segment(0);
            knuckle_segment(12);
            knuckle_segment(24);
        }
        for (yy = screw_y)
            countersunk_hole(yy, -18, true);
    }
}

module right_leaf() {
    difference() {
        union() {
            leaf_base("right");
            knuckle_segment(6);
            knuckle_segment(18);
        }
        for (yy = screw_y)
            countersunk_hole(yy, 18, true);
    }
}

// ===== Assembly: 180° open =====
left_leaf();
right_leaf();
pin_axis();