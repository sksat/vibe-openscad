plate_length = 30;
plate_width = 25;
plate_thickness = 2;
hole_edge_offset = 5;
hole_positions = [-8, 0, 8];

knuckle_segment_length = 6;
knuckle_outer_d = 8;
knuckle_inner_d = 4.6;

pin_d = 4;
pin_length = 32;

left_knuckle_centers = [-12, 0, 12];
right_knuckle_centers = [-6, 6];

$fn = 96;

module countersunk_cut(x, y) {
    union() {
        translate([x, y, plate_thickness - 1])
            cylinder(h = 1, r1 = 1.6, r2 = 3, $fn = 64);
        translate([x, y, -1])
            cylinder(h = plate_thickness + 4, r = 1.6, $fn = 64);
    }
}

module knuckle_segment(yc) {
    translate([0, yc, plate_thickness / 2])
        rotate([-90, 0, 0])
            difference() {
                cylinder(h = knuckle_segment_length, r = knuckle_outer_d / 2, center = true);
                cylinder(h = knuckle_segment_length + 0.4, r = knuckle_inner_d / 2, center = true);
            }
}

module leaf_plate(side = "left") {
    x_start = (side == "left") ? -plate_width : 0;
    hole_x = (side == "left") ? (-plate_width + hole_edge_offset) : (plate_width - hole_edge_offset);
    difference() {
        translate([x_start, -plate_length / 2, 0])
            cube([plate_width, plate_length, plate_thickness]);
        for (ypos = hole_positions)
            countersunk_cut(hole_x, ypos);
    }
}

module knuckles(side = "left") {
    centers = (side == "left") ? left_knuckle_centers : right_knuckle_centers;
    for (yc = centers)
        knuckle_segment(yc);
}

module hinge_leaf(side = "left") {
    union() {
        leaf_plate(side);
        knuckles(side);
    }
}

module pin_axis() {
    translate([0, 0, plate_thickness / 2])
        rotate([-90, 0, 0])
            cylinder(h = pin_length, r = pin_d / 2, center = true);
}

hinge_leaf("left");
hinge_leaf("right");
pin_axis();