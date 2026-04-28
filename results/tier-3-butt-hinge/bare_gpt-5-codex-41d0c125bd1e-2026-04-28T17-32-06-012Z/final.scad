$fn = 96;

plate_thickness = 2;
leaf_length = 25;
leaf_height = 30;
knuckle_outer_d = 8;
knuckle_inner_d = 4.6;
knuckle_segment_len = leaf_height / 5;
pin_d = 4;
pin_length = 32;
hole_d = 3.2;
countersink_top_d = 6;
countersink_depth = 1;
hole_pitch = 8;
hole_edge_offset = 7;

function knuckle_center(idx) = -leaf_height / 2 + (idx + 0.5) * knuckle_segment_len;

module knuckle_shell(idx) {
    translate([0, knuckle_center(idx), 0])
        rotate([90, 0, 0])
            difference() {
                cylinder(h = knuckle_segment_len, d = knuckle_outer_d, center = true);
                cylinder(h = knuckle_segment_len + 0.2, d = knuckle_inner_d, center = true);
            }
}

module knuckle_clearance(idx) {
    translate([0, knuckle_center(idx), 0])
        rotate([90, 0, 0])
            cylinder(h = knuckle_segment_len + 0.2, d = knuckle_outer_d, center = true);
}

module pin_channel() {
    rotate([90, 0, 0])
        cylinder(h = leaf_height + 0.4, d = knuckle_inner_d, center = true);
}

module countersunk_hole(pos) {
    union() {
        translate([pos[0], pos[1], -plate_thickness / 2 - 0.2])
            cylinder(h = plate_thickness + 0.4, d = hole_d);
        translate([pos[0], pos[1], plate_thickness / 2 - countersink_depth])
            cylinder(h = countersink_depth, r1 = hole_d / 2, r2 = countersink_top_d / 2);
    }
}

module leaf(side = "left") {
    indices_self = (side == "left") ? [0, 2, 4] : [1, 3];
    indices_other = (side == "left") ? [1, 3] : [0, 2, 4];
    hole_x = (side == "left") ? (-leaf_length + hole_edge_offset) : (leaf_length - hole_edge_offset);
    hole_positions_y = [-hole_pitch, 0, hole_pitch];

    difference() {
        union() {
            translate([(side == "left") ? -leaf_length : 0, -leaf_height / 2, -plate_thickness / 2])
                cube([leaf_length, leaf_height, plate_thickness]);
            for (idx = indices_self)
                knuckle_shell(idx);
        }
        union() {
            for (idx = indices_other)
                knuckle_clearance(idx);
            pin_channel();
            for (ypos = hole_positions_y)
                countersunk_hole([hole_x, ypos]);
        }
    }
}

module hinge_pin() {
    rotate([90, 0, 0])
        cylinder(h = pin_length, d = pin_d, center = true);
}

union() {
    leaf("left");
    leaf("right");
    hinge_pin();
}