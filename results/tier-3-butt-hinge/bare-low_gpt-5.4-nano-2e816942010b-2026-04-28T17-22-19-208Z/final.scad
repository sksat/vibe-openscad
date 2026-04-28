$fn = 64;

// ---------------------- Parameters ----------------------
leaf_len_y = 30;          // along Y
leaf_len_x = 25;          // along X (opening direction)
leaf_thk_z = 2;

knuckle_count_total = 5;
knuckle_seg = 6;          // 30 / 5
knuckle_outer_d = 8;      // outer diameter
pin_d = 4;                // pin diameter
clearance = 0.3;
knuckle_inner_d = pin_d + clearance; // 4.6
knuckle_len_y = knuckle_seg;

pin_len_y = 32;          // 1mm overhang each side (30 + 2)
pin_overhang = 1;

hole_pitch_y = 8;
hole_count = 3;          // y positions: -8, 0, +8
hole_y0 = 0;

screw_d = 3.2;          // through hole diameter
csk_d = 6;              // countersink top diameter
csk_depth = 1;          // countersink depth

leaf_free_edge_offset = 2; // from free edge along X for countersink location (assumed)

knuckle_y_positions = [-12, -6, 0, 6, 12]; // 5 segments over 30mm
left_knuckle_idx  = [0, 2, 4]; // outer, middle
right_knuckle_idx = [1, 3];    // middle two

// ---------------------- Helpers ----------------------
module leaf_plate_with_knuckles(is_left=true) {
    x_min = is_left ? -leaf_len_x : 0;
    x_max = is_left ? 0 : leaf_len_x;
    x_center = (x_min + x_max) / 2;

    difference() {
        // Leaf plate
        translate([x_center, 0, 0])
            cube([leaf_len_x, leaf_len_y, leaf_thk_z], center=true);

        // Knuckle bores on this leaf (to be subtracted from each knuckle barrel)
        for (i = (is_left ? left_knuckle_idx : right_knuckle_idx)) {
            y = knuckle_y_positions[i];
            translate([0, y, 0])
                rotate([90,0,0]) // axis along Y
                    cylinder(h=leaf_thk_z+0.2, d=knuckle_inner_d, center=true);
        }

        // M3 countersunk holes (axis along Z through thickness)
        // Location: near free edge side, on face perpendicular to Z; assumed centered at Z=0.
        for (k = [0:hole_count-1]) {
            y = hole_y0 + (k - (hole_count-1)/2) * hole_pitch_y;

            x = is_left ? (-leaf_len_x + leaf_free_edge_offset) : (leaf_len_x - leaf_free_edge_offset);

            // Through hole
            translate([x, y, 0])
                cylinder(h=leaf_thk_z+4, d=screw_d, center=true);

            // Countersink (taper)
            // Make taper on the same Z side (+Z) for both leaves (open state is coplanar).
            translate([x, y, leaf_thk_z/2])  // top surface z = +1
                rotate([0,0,0])
                    translate([0,0,-csk_depth/2])
                        cylinder(h=csk_depth, d1=csk_d, d2=screw_d, center=true);
        }
    }

    // Add knuckle barrels (with outer diameter), but keep only the portion within plate thickness
    for (i = (is_left ? left_knuckle_idx : right_knuckle_idx)) {
        y = knuckle_y_positions[i];

        // Barrel solid limited to plate thickness by intersection with a slab
        intersection() {
            translate([0, y, 0])
                rotate([90,0,0]) // axis along Y
                    cylinder(h=knuckle_len_y, d=knuckle_outer_d, center=true);

            // slab to limit to leaf thickness in Z
            translate([0, 0, 0])
                cube([leaf_len_x*3, leaf_len_y, leaf_thk_z], center=true);
        }
    }
}

module pin() {
    translate([0, 0, 0])
        rotate([90,0,0]) // axis along Y
            cylinder(h=pin_len_y, d=pin_d, center=true);
}

// ---------------------- Assembly: open state (180°) ----------------------
// Leaves are coplanar; left at x<0, right at x>0 sharing pin axis at X=0.

union() {
    // Pin axis (for visual/assembled state)
    pin();

    // Leaves with knuckles and screw holes
    leaf_plate_with_knuckles(true);  // left
    leaf_plate_with_knuckles(false); // right
}

// Ensure knuckles align at X=0 and Y spacing is centered at y=0.