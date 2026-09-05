$fn = 60;

// Dimensions
leaf_length = 30;     // Y direction (along hinge pin)
leaf_width = 25;      // X direction
leaf_thickness = 2;   // Z direction
pin_dia = 4;
pin_length = 32;
knuckle_od = 8;
knuckle_id = 4.6;
knuckle_count = 5;
seg_len = leaf_length / knuckle_count; // 6mm

hole_dia = 3.2;
countersink_top_dia = 6;
countersink_depth = 1;
hole_pitch = 8;
hole_x_offset = 14; // Distance from axis to mounting holes

// M3 Countersunk Screw Hole (oriented along Z axis)
module countersink_hole() {
    // Through hole
    cylinder(d = hole_dia, h = leaf_thickness + 2, center = true);
    // Countersink cone on top face (Z = leaf_thickness)
    translate([0, 0, leaf_thickness - countersink_depth])
        cylinder(r1 = hole_dia / 2, r2 = countersink_top_dia / 2, h = countersink_depth + 0.01);
}

// Single Knuckle Segment
module knuckle_segment(y_pos) {
    translate([0, y_pos, knuckle_od / 2 - leaf_thickness])
        rotate([-90, 0, 0])
            difference() {
                cylinder(d = knuckle_od, h = seg_len);
                translate([0, 0, -1])
                    cylinder(d = knuckle_id, h = seg_len + 2);
            }
}

// Leaf Plate with mounting holes
module leaf_plate(is_left = false) {
    x_pos = is_left ? -leaf_width : 0;
    hole_x = is_left ? -hole_x_offset : hole_x_offset;
    
    difference() {
        // Flat plate
        translate([x_pos, 0, 0])
            cube([leaf_width, leaf_length, leaf_thickness]);
        
        // 3 Countersunk holes
        for (i = [-1, 0, 1]) {
            translate([hole_x, leaf_length / 2 + i * hole_pitch, 0])
                countersink_hole();
        }
    }
}

// Left Leaf Component (Knuckles at indices 0, 2, 4)
module left_leaf() {
    color("silver") {
        leaf_plate(is_left = true);
        knuckle_segment(0 * seg_len);
        knuckle_segment(2 * seg_len);
        knuckle_segment(4 * seg_len);
    }
}

// Right Leaf Component (Knuckles at indices 1, 3)
module right_leaf() {
    color("lightgray") {
        leaf_plate(is_left = false);
        knuckle_segment(1 * seg_len);
        knuckle_segment(3 * seg_len);
    }
}

// Hinge Pin
module hinge_pin() {
    color("darkgray")
        translate([0, (leaf_length - pin_length) / 2, knuckle_od / 2 - leaf_thickness])
            rotate([-90, 0, 0])
                cylinder(d = pin_dia, h = pin_length);
}

// Assembly: 180° Open Butt Hinge
left_leaf();
right_leaf();
hinge_pin();