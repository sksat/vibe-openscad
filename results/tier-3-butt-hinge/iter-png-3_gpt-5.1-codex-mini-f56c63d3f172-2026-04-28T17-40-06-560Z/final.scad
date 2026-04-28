$fn = 64;

leaf_width = 25;
leaf_length = 30;
leaf_thickness = 2;

knuckle_length = 6;
knuckle_outer_radius = 4;
knuckle_inner_radius = 2.3;

pin_diameter = 4;
pin_length = 32;

left_knuckle_centers = [-12, 0, 12];
right_knuckle_centers = [-6, 6];
countersink_positions = [-8, 0, 8];

countersink_depth = 1;
countersink_top_radius = 3;
through_hole_radius = 3.2 / 2;
countersink_side_margin = 3;

module knuckle_half(side, posY) {
    intersection() {
        translate([side == "left" ? -leaf_width : 0, posY - knuckle_length / 2, 0])
            cube([leaf_width, knuckle_length, leaf_thickness], center = false);
        translate([0, posY, leaf_thickness / 2])
            rotate([-90, 0, 0])
            cylinder(h = knuckle_length, r = knuckle_outer_radius, center = true);
    }
}

module knuckle_core(posY) {
    translate([0, posY, leaf_thickness / 2])
        rotate([-90, 0, 0])
        cylinder(h = knuckle_length, r = knuckle_inner_radius, center = true);
}

module countersink_hole(side, posY) {
    x = side == "left" ? -leaf_width + countersink_side_margin : leaf_width - countersink_side_margin;
    union() {
        translate([x, posY, leaf_thickness - countersink_depth])
            cylinder(h = countersink_depth, r1 = through_hole_radius, r2 = countersink_top_radius, center = false);
        translate([x, posY, -1])
            cylinder(h = leaf_thickness + 2, r = through_hole_radius, center = false);
    }
}

module leaf(side = "left") {
    knuckle_centers = side == "left" ? left_knuckle_centers : right_knuckle_centers;
    translate_x = side == "left" ? -leaf_width : 0;

    difference() {
        union() {
            translate([translate_x, -leaf_length / 2, 0])
                cube([leaf_width, leaf_length, leaf_thickness], center = false);
            for (posY = knuckle_centers)
                knuckle_half(side, posY);
        }
        for (posY = knuckle_centers)
            knuckle_core(posY);
        for (posY = countersink_positions)
            countersink_hole(side, posY);
    }
}

module hinge_pin() {
    translate([0, 0, leaf_thickness / 2])
        rotate([-90, 0, 0])
        cylinder(h = pin_length, r = pin_diameter / 2, center = true);
}

union() {
    leaf("left");
    leaf("right");
    hinge_pin();
}