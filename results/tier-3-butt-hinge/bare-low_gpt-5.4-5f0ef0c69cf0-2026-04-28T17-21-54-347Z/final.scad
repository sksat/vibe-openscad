$fn = 96;

leaf_len = 30;
leaf_w   = 25;
leaf_t   = 2;

pin_d    = 4;
pin_r    = pin_d / 2;
pin_len  = 32;

knuckle_od = 8;
knuckle_id = 4.6;
knuckle_r  = knuckle_od / 2;
knuckle_len = 6;

hole_d   = 3.2;
csk_d    = 6;
csink_h  = 1;

left_x0  = -knuckle_r - leaf_w;   // -29
right_x0 =  knuckle_r;            // 4
z0       = -leaf_t / 2;

hole_ys = [7, 15, 23];
left_hole_x  = left_x0  + 7;      // near free edge
right_hole_x = right_x0 + 18;     // near free edge

module pin_axis_cyl(y0, h, d) {
    translate([0, y0, 0])
        rotate([-90, 0, 0])
            cylinder(h = h, d = d);
}

module countersunk_hole(x, y) {
    union() {
        translate([x, y, -leaf_t])
            cylinder(h = leaf_t * 3, d = hole_d);
        translate([x, y, 0])
            cylinder(h = csink_h, d1 = hole_d, d2 = csk_d);
    }
}

module left_leaf() {
    difference() {
        union() {
            translate([left_x0, 0, z0])
                cube([leaf_w, leaf_len, leaf_t]);

            for (y0 = [0, 12, 24])
                pin_axis_cyl(y0, knuckle_len, knuckle_od);
        }

        pin_axis_cyl(0, leaf_len, knuckle_id);

        for (y = hole_ys)
            countersunk_hole(left_hole_x, y);
    }
}

module right_leaf() {
    difference() {
        union() {
            translate([right_x0, 0, z0])
                cube([leaf_w, leaf_len, leaf_t]);

            for (y0 = [6, 18])
                pin_axis_cyl(y0, knuckle_len, knuckle_od);
        }

        pin_axis_cyl(0, leaf_len, knuckle_id);

        for (y = hole_ys)
            countersunk_hole(right_hole_x, y);
    }
}

module pin() {
    pin_axis_cyl(-1, pin_len, pin_d);
}

color("silver") left_leaf();
color("silver") right_leaf();
color("gainsboro") pin();