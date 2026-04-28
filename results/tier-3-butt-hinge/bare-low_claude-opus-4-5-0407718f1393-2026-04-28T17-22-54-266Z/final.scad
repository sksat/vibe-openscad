// Butt Hinge - 180° open position

// Parameters
leaf_width = 25;
leaf_height = 30;
leaf_thickness = 2;

pin_diameter = 4;
pin_length = 32;
pin_clearance = 0.3;

knuckle_od = 8;
knuckle_id = pin_diameter + pin_clearance;
knuckle_height = 6;

hole_diameter = 3.2;
countersink_diameter = 6;
countersink_depth = 1;
hole_spacing = 8;

// Countersunk hole module
module countersunk_hole() {
    union() {
        cylinder(d=hole_diameter, h=leaf_thickness+1, $fn=32);
        translate([0, 0, leaf_thickness - countersink_depth])
            cylinder(d1=hole_diameter, d2=countersink_diameter, h=countersink_depth+0.01, $fn=32);
    }
}

// Leaf with knuckles
module leaf(knuckle_positions) {
    difference() {
        union() {
            // Plate
            translate([0, 0, -leaf_thickness/2])
                cube([leaf_width, leaf_height, leaf_thickness]);
            // Knuckles
            for (i = knuckle_positions) {
                translate([0, i * knuckle_height, 0])
                    rotate([-90, 0, 0])
                        difference() {
                            cylinder(d=knuckle_od, h=knuckle_height, $fn=48);
                            translate([0, 0, -0.5])
                                cylinder(d=knuckle_id, h=knuckle_height+1, $fn=48);
                        }
            }
        }
        // Countersunk holes
        hole_x = leaf_width - 8;
        for (j = [0:2]) {
            translate([hole_x, 3 + j * hole_spacing, -leaf_thickness/2 - 0.5])
                countersunk_hole();
        }
    }
}

// Pin
module pin() {
    translate([0, -1, 0])
        rotate([-90, 0, 0])
            cylinder(d=pin_diameter, h=pin_length, $fn=48);
}

// Assembly
// Left leaf (knuckles at positions 0, 2, 4)
translate([0, 0, 0])
    rotate([0, 0, 180])
        leaf([0, 2, 4]);

// Right leaf (knuckles at positions 1, 3)
leaf([1, 3]);

// Pin
color("silver") pin();