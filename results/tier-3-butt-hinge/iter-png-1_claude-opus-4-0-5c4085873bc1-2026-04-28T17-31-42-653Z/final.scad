// Butt hinge parameters
leaf_width = 25;
leaf_height = 30;
leaf_thickness = 2;
pin_diameter = 4;
pin_length = 32;
knuckle_outer_diameter = 8;
knuckle_inner_diameter = 4.6;
knuckle_height = 6;
num_knuckles = 5;

// Screw hole parameters
screw_hole_diameter = 3.2;
countersink_diameter = 6;
countersink_depth = 1;
screw_spacing = 8;

$fn = 50;

// Pin (centered on Y-axis)
color("Silver")
translate([0, -1, 0])
cylinder(h = pin_length, d = pin_diameter);

// Left leaf (x < 0)
color("DarkGray")
difference() {
    union() {
        // Flat plate
        translate([-leaf_width, 0, -leaf_thickness/2])
        cube([leaf_width - knuckle_outer_diameter/2, leaf_height, leaf_thickness]);
        
        // Knuckles (positions 0, 2, 4)
        for (i = [0, 2, 4]) {
            translate([0, i * knuckle_height, 0])
            difference() {
                // Full cylinder
                cylinder(h = knuckle_height, d = knuckle_outer_diameter);
                // Inner hole
                cylinder(h = knuckle_height, d = knuckle_inner_diameter);
                // Cut right half
                translate([0, 0, -knuckle_height/2])
                cube([knuckle_outer_diameter, knuckle_outer_diameter, knuckle_height * 2]);
            }
        }
    }
    
    // Screw holes
    for (i = [0, 1, 2]) {
        translate([-leaf_width * 0.6, leaf_height/2 + (i - 1) * screw_spacing, 0]) {
            // Through hole
            cylinder(h = leaf_thickness + 1, d = screw_hole_diameter, center = true);
            // Countersink
            translate([0, 0, leaf_thickness/2 - countersink_depth])
            cylinder(h = countersink_depth + 0.1, d1 = screw_hole_diameter, d2 = countersink_diameter);
        }
    }
}

// Right leaf (x > 0)
color("DarkGray")
difference() {
    union() {
        // Flat plate
        translate([knuckle_outer_diameter/2, 0, -leaf_thickness/2])
        cube([leaf_width - knuckle_outer_diameter/2, leaf_height, leaf_thickness]);
        
        // Knuckles (positions 1, 3)
        for (i = [1, 3]) {
            translate([0, i * knuckle_height, 0])
            difference() {
                // Full cylinder
                cylinder(h = knuckle_height, d = knuckle_outer_diameter);
                // Inner hole
                cylinder(h = knuckle_height, d = knuckle_inner_diameter);
                // Cut left half
                translate([-knuckle_outer_diameter, 0, -knuckle_height/2])
                cube([knuckle_outer_diameter, knuckle_outer_diameter, knuckle_height * 2]);
            }
        }
    }
    
    // Screw holes
    for (i = [0, 1, 2]) {
        translate([leaf_width * 0.6, leaf_height/2 + (i - 1) * screw_spacing, 0]) {
            // Through hole
            cylinder(h = leaf_thickness + 1, d = screw_hole_diameter, center = true);
            // Countersink
            translate([0, 0, leaf_thickness/2 - countersink_depth])
            cylinder(h = countersink_depth + 0.1, d1 = screw_hole_diameter, d2 = countersink_diameter);
        }
    }
}