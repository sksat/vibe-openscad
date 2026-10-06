// Parameters
leaf_h = 30;        // Height (along Y axis)
leaf_w = 25;        // Width (along X axis)
leaf_t = 2;         // Thickness
pin_d = 4;          // Pin diameter
pin_l = 32;         // Pin length
knuckle_od = 8;     // Knuckle outer diameter
knuckle_id = pin_d + 0.3; // Knuckle inner diameter
knuckle_seg = 6;    // Segment length (30/5)

$fn = 64;

module screw_hole() {
    // M3 Countersink: 6mm diameter, 1mm depth taper
    cylinder(h = 1, r1 = 3, r2 = 1.6); 
    // M3 Clearance: 3.2mm diameter through hole
    translate([0, 0, -1]) cylinder(h = leaf_t + 2, r = 1.6);
}

module leaf_with_knuckles(is_left) {
    union() {
        // Main leaf plate
        translate([is_left ? -leaf_w : 0, 0, -leaf_t/2])
            cube([leaf_w, leaf_h, leaf_t]);

        // Knuckles
        for (i = [0 : 4]) {
            // Left leaf gets segments 0, 2, 4 (indices)
            // Right leaf gets segments 1, 3
            if ((is_left && i % 2 == 0) || (!is_left && i % 2 != 0)) {
                translate([0, i * knuckle_seg, 0])
                difference() {
                    cylinder(h = knuckle_seg, d = knuckle_od, center = true);
                    cylinder(h = knuckle_seg + 1, d = knuckle_id, center = true);
                }
            }
        }

        // Screw holes (3 holes, 8mm pitch)
        for (j = [0 : 2]) {
            translate([
                is_left ? -leaf_w + 5 : leaf_w - 5, 
                (leaf_h/2) - (leaf_h/2) + (j + 1) * 8 - 8, // centered logic
                leaf_t/2
            ])
            // Recalculate Y for 8mm pitch centered in 30mm (e.g. 7, 15, 23)
            // Using fixed offsets from bottom: 7, 15, 23
            translate([0, (j+1)*8 - 8, 0]) // Adjusted below in final loop
            rotate([90, 0, 0]) screw_hole();
        }
    }
}

// Corrected screw hole placement for the leaf
module leaf_fixed(is_left) {
    union() {
        // Plate
        translate([is_left ? -leaf_w : 0, 0, -leaf_t/2])
            cube([leaf_w, leaf_h, leaf_t]);
        
        // Knuckles
        for (i = [0 : 4]) {
            if ((is_left && i % 2 == 0) || (!is_left && i % 2 != 0)) {
                translate([0, i * knuckle_seg + knuckle_seg/2, 0])
                difference() {
                    cylinder(h = knuckle_seg, d = knuckle_od, center = true);
                    cylinder(h = knuckle_seg + 1, d = knuckle_id, center = true);
                }
            }
        }
        
        // Holes at Y = 7, 15, 23
        for (y_pos = [7, 15, 23]) {
            translate([is_left ? -leaf_w + 5 : leaf_w - 5, y_pos, leaf_t/2])
            rotate([90, 0, 0]) screw_hole();
        }
    }
}

// Final Assembly
// Pin Axis: Y axis
// Left Leaf: x < 0
// Right Leaf: x > 0
// Opened state: 180 degrees (plates on same plane Z)

// 1. Left Leaf
color("silver") leaf_fixed(true);

// 2. Right Leaf
color("silver") leaf_fixed(false);

// 3. Pin
color("gray") 
translate([0, -1, 0]) 
cylinder(h = pin_l, d = pin_d);