// Butt Hinge - Furniture Small Size
// Three parts: Left leaf, Right leaf, Pin

// Parameters
leaf_length = 30;      // Y direction (along hinge axis)
leaf_width = 25;       // X direction (opening direction)
leaf_thickness = 2;    // Z direction

pin_diameter = 4;
pin_length = 32;
pin_clearance = 0.3;

knuckle_outer_diameter = 8;
knuckle_inner_diameter = pin_diameter + pin_clearance;
knuckle_radius = knuckle_outer_diameter / 2;
knuckle_height = 6;    // 30mm / 5 = 6mm each

// Countersunk hole parameters
hole_diameter = 3.2;
countersink_diameter = 6;
countersink_depth = 1;
hole_spacing = 8;
hole_offset_from_edge = 12.5;  // Center of holes from outer edge of leaf

$fn = 64;

// Module for countersunk hole (countersink on top, hole goes through)
module countersunk_hole() {
    // Countersink from top surface
    translate([0, 0, leaf_thickness - countersink_depth])
        cylinder(h = countersink_depth + 0.01, d1 = hole_diameter, d2 = countersink_diameter);
    // Through hole
    translate([0, 0, -0.01])
        cylinder(h = leaf_thickness + 0.02, d = hole_diameter);
}

// Module for knuckle cylinder
module knuckle_cylinder(height) {
    difference() {
        // Outer cylinder
        cylinder(h = height, d = knuckle_outer_diameter);
        // Inner hole for pin
        translate([0, 0, -0.01])
            cylinder(h = height + 0.02, d = knuckle_inner_diameter);
    }
}

// Module for left leaf (3 knuckles: positions 0, 2, 4)
module left_leaf() {
    difference() {
        union() {
            // Main plate - extends in -X direction from knuckle center
            // Plate top surface at z = leaf_thickness, bottom at z = 0
            // Knuckle center (pin axis) is at z = -knuckle_radius (below plate bottom)
            translate([-leaf_width + knuckle_radius, 0, 0])
                cube([leaf_width - knuckle_radius, leaf_length, leaf_thickness]);
            
            // Transition piece connecting plate to knuckle
            translate([0, 0, 0])
                difference() {
                    translate([-knuckle_radius, 0, -knuckle_radius])
                        cube([knuckle_radius, leaf_length, knuckle_radius + leaf_thickness]);
                    // Cut out the cylinder space
                    translate([0, -0.01, -knuckle_radius])
                        rotate([-90, 0, 0])
                            cylinder(h = leaf_length + 0.02, d = knuckle_outer_diameter);
                }
            
            // Knuckles at positions 0, 2, 4 (left leaf gets 1st, 3rd, 5th)
            for (i = [0, 2, 4]) {
                translate([0, i * knuckle_height, -knuckle_radius])
                    rotate([-90, 0, 0])
                        knuckle_cylinder(knuckle_height);
            }
        }
        
        // Countersunk holes (3 holes along Y axis)
        // Positioned toward the outer edge of the leaf
        for (i = [-1, 0, 1]) {
            translate([-leaf_width + knuckle_radius + hole_offset_from_edge, 
                       leaf_length/2 + i * hole_spacing, 0])
                countersunk_hole();
        }
    }
}

// Module for right leaf (2 knuckles: positions 1, 3)
module right_leaf() {
    difference() {
        union() {
            // Main plate - extends in +X direction from knuckle center
            translate([0, 0, 0])
                cube([leaf_width - knuckle_radius, leaf_length, leaf_thickness]);
            
            // Transition piece connecting plate to knuckle
            difference() {
                translate([0, 0, -knuckle_radius])
                    cube([knuckle_radius, leaf_length, knuckle_radius + leaf_thickness]);
                // Cut out the cylinder space
                translate([0, -0.01, -knuckle_radius])
                    rotate([-90, 0, 0])
                        cylinder(h = leaf_length + 0.02, d = knuckle_outer_diameter);
            }
            
            // Knuckles at positions 1, 3 (right leaf gets 2nd, 4th)
            for (i = [1, 3]) {
                translate([0, i * knuckle_height, -knuckle_radius])
                    rotate([-90, 0, 0])
                        knuckle_cylinder(knuckle_height);
            }
        }
        
        // Countersunk holes (3 holes along Y axis)
        for (i = [-1, 0, 1]) {
            translate([leaf_width - knuckle_radius - hole_offset_from_edge, 
                       leaf_length/2 + i * hole_spacing, 0])
                countersunk_hole();
        }
    }
}

// Module for pin
module pin() {
    translate([0, -1, -knuckle_radius])
        rotate([-90, 0, 0])
            cylinder(h = pin_length, d = pin_diameter);
}

// Assembly - 180° open position
// Both plates lie flat with top surfaces coplanar (z = leaf_thickness)
// Pin axis along Y at x=0, z=-knuckle_radius

// Left leaf
color("DarkGray")
    left_leaf();

// Right leaf
color("Gray")
    right_leaf();

// Pin
color("Silver")
    pin();