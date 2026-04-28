// Parameters
leaf_width = 25;
leaf_height = 30;
leaf_thickness = 2;
pin_diameter = 4;
pin_length = 32;
knuckle_outer_diameter = 8;
knuckle_inner_diameter = pin_diameter + 0.3;
knuckle_height = 6; // 30mm / 5 equal parts
num_knuckles_left = 3;
num_knuckles_right = 2;
m3_countersink_diameter = 6;
m3_countersink_depth = 1;
m3_hole_diameter = 3.2;
m3_hole_spacing = 8;

module pin() {
    cylinder(h = pin_length, d = pin_diameter, center = true);
}

module knuckle(side_multiplier) {
    difference() {
        cylinder(h = knuckle_height, d = knuckle_outer_diameter, center = true);
        cylinder(h = knuckle_height + 0.1, d = knuckle_inner_diameter, center = true); // +0.1 to ensure clean cut
    }
}

module leaf(side) {
    // Base leaf shape
    cube([leaf_thickness, leaf_width, leaf_height], center = true);

    // Mount holes
    translate([side * (leaf_thickness / 2), 0, -m3_hole_spacing]) {
        m3_countersink(side);
    }
    translate([side * (leaf_thickness / 2), 0, 0]) {
        m3_countersink(side);
    }
    translate([side * (leaf_thickness / 2), 0, m3_hole_spacing]) {
        m3_countersink(side);
    }
}

module m3_countersink(side) {
    rotate([90, 0, 0]) {
        cylinder(h = m3_countersink_depth, d = m3_countersink_diameter, center = true);
        translate([0, 0, m3_countersink_depth]) {
            cylinder(h = m3_hole_diameter, d = m3_hole_diameter, center = true);
        }
    }
}

// Assemble the hinge in 180 degree open state
module butt_hinge() {
    // Pin
    pin();

    // Left leaf and its knuckles
    left_leaf_x_offset = -knuckle_outer_diameter / 2 - leaf_thickness / 2;
    translate([left_leaf_x_offset, 0, 0]) {
        leaf(-1); // Left side
    }

    // Knuckles for the left leaf (interleaved)
    knuckle_y_offset_start = -(num_knuckles_left - 1) * knuckle_height / 2;
    for (i = [0 : num_knuckles_left - 1]) {
        // Knuckles for the left leaf are on the "outer" side relative to the pin
        // When open 180, left leaf is on x < 0, right leaf is on x > 0.
        // Knuckles for left leaf should be on the side closer to its leaf, so their outer surfaces will align with leaf surfaces when closed.
        // For 180 degree open, the knuckles will be on the "outside" of the pin's central axis.
        // Left leaf is on x < 0. Knuckles are on the "outer" side of the pin.
        translate([0, knuckle_y_offset_start + i * knuckle_height, 0]) {
            knuckle(-1); // Left side
        }
    }

    // Right leaf and its knuckles
    right_leaf_x_offset = knuckle_outer_diameter / 2 + leaf_thickness / 2;
    translate([right_leaf_x_offset, 0, 0]) {
        leaf(1); // Right side
    }

    // Knuckles for the right leaf (interleaved)
    knuckle_y_offset_start_right = -(num_knuckles_right - 1) * knuckle_height / 2;
    for (i = [0 : num_knuckles_right - 1]) {
        // Knuckles for the right leaf are on the "outer" side relative to the pin.
        // For 180 degree open, the knuckles will be on the "outside" of the pin's central axis.
        // Right leaf is on x > 0. Knuckles are on the "outer" side of the pin.
        translate([0, knuckle_y_offset_start_right + i * knuckle_height, 0]) {
            knuckle(1); // Right side
        }
    }
}

// Position the hinge at the origin
translate([0, 0, 0]) {
    butt_hinge();
}