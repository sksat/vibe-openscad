$fn = 96;

// ===== Parameters =====
leaf_len = 30;          // along hinge axis (Y)
leaf_w   = 25;          // opening direction (X)
leaf_t   = 2;           // plate thickness (Z)

pin_d = 4;
pin_r = pin_d / 2;
pin_len = 32;           // 30 mm knuckle stack + 1 mm protrusion each end

knuckle_od = 8;
knuckle_or = knuckle_od / 2;
knuckle_id = 4.6;       // 4.0 + 0.3 clearance radial? per prompt given as hole dia 4.6
knuckle_ir = knuckle_id / 2;
knuckle_seg = 6;        // 30 / 5

through_d = 3.2;
csk_d = 6.0;
csk_depth = 1.0;

screw_y = [7, 15, 23];
screw_x_left  = -18;
screw_x_right =  18;

// Common plate top surface at Z=0 in 180° open state
leaf_z0 = -leaf_t;

// ===== Modules =====
module pin_axis() {
    // centered on Y-axis, protruding 1 mm beyond knuckle stack at both ends
    translate([0, -1, 0])
        rotate([-90, 0, 0])
            cylinder(h = pin_len, r = pin_r);
}

module knuckle_tube(y0) {
    translate([0, y0, 0])
        rotate([-90, 0, 0])
            difference() {
                cylinder(h = knuckle_seg, r = knuckle_or);
                cylinder(h = knuckle_seg, r = knuckle_ir);
            }
}

module countersunk_hole(x, y) {
    translate([x, y, leaf_z0]) {
        cylinder(h = leaf_t + 0.02, d = through_d);
        translate([0, 0, leaf_t - csk_depth])
            cylinder(h = csk_depth + 0.02, d1 = through_d, d2 = csk_d);
    }
}

module leaf_body(side="left") {
    if (side == "left") {
        translate([-leaf_w, 0, leaf_z0])
            cube([leaf_w, leaf_len, leaf_t]);
    } else {
        translate([0, 0, leaf_z0])
            cube([leaf_w, leaf_len, leaf_t]);
    }
}

module left_leaf() {
    difference() {
        union() {
            leaf_body("left");
            knuckle_tube(0);
            knuckle_tube(12);
            knuckle_tube(24);
        }
        for (yy = screw_y)
            countersunk_hole(screw_x_left, yy);
    }
}

module right_leaf() {
    difference() {
        union() {
            leaf_body("right");
            knuckle_tube(6);
            knuckle_tube(18);
        }
        for (yy = screw_y)
            countersunk_hole(screw_x_right, yy);
    }
}

// ===== Assembly =====
left_leaf();
right_leaf();
pin_axis();