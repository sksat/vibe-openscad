$fn = 96;

leaf_y = 30;
leaf_w = 25;
plate_t = 2;

pin_d = 4;
pin_len = 32;

knuckle_od = 8;
knuckle_id = 4.6;
knuckle_r = knuckle_od / 2;
seg_len = 6;

through_d = 3.2;
cs_d = 6;
cs_depth = 1;

eps = 0.02;
barrel_clearance = 0.08;
connector_overlap = 0.22;

left_inner_x  = -knuckle_r - barrel_clearance;
left_outer_x  = left_inner_x - leaf_w;
right_inner_x =  knuckle_r + barrel_clearance;
right_outer_x = right_inner_x + leaf_w;

screw_edge_margin = 7;
left_screw_x  = left_outer_x + screw_edge_margin;
right_screw_x = right_outer_x - screw_edge_margin;

module y_cylinder(h, d, center=true) {
    rotate([-90, 0, 0])
        cylinder(h=h, d=d, center=center);
}

module screw_hole(x, y) {
    translate([x, y, 0])
        cylinder(h=plate_t + 2 * eps, d=through_d, center=true);

    translate([x, y, plate_t / 2 - cs_depth])
        cylinder(h=cs_depth + eps, d1=through_d, d2=cs_d, center=false);
}

module knuckle(yc) {
    translate([0, yc, 0])
        difference() {
            y_cylinder(seg_len, knuckle_od, center=true);
            y_cylinder(seg_len + 2 * eps, knuckle_id, center=true);
        }
}

module left_connector(yc) {
    x1 = left_inner_x - connector_overlap;
    x2 = -knuckle_r + connector_overlap;
    translate([(x1 + x2) / 2, yc, 0])
        cube([x2 - x1, seg_len, plate_t], center=true);
}

module right_connector(yc) {
    x1 = knuckle_r - connector_overlap;
    x2 = right_inner_x + connector_overlap;
    translate([(x1 + x2) / 2, yc, 0])
        cube([x2 - x1, seg_len, plate_t], center=true);
}

module left_plate() {
    translate([(left_outer_x + left_inner_x) / 2, 0, 0])
        cube([leaf_w, leaf_y, plate_t], center=true);
}

module right_plate() {
    translate([(right_inner_x + right_outer_x) / 2, 0, 0])
        cube([leaf_w, leaf_y, plate_t], center=true);
}

module left_leaf() {
    difference() {
        union() {
            left_plate();
            for (yc = [-12, 0, 12]) {
                knuckle(yc);
                left_connector(yc);
            }
        }
        for (yh = [-8, 0, 8])
            screw_hole(left_screw_x, yh);
    }
}

module right_leaf() {
    difference() {
        union() {
            right_plate();
            for (yc = [-6, 6]) {
                knuckle(yc);
                right_connector(yc);
            }
        }
        for (yh = [-8, 0, 8])
            screw_hole(right_screw_x, yh);
    }
}

module pin_axis() {
    y_cylinder(pin_len, pin_d, center=true);
}

color([0.50, 0.50, 0.50])
    left_leaf();

color([0.62, 0.62, 0.62])
    right_leaf();

color([0.18, 0.18, 0.18])
    pin_axis();