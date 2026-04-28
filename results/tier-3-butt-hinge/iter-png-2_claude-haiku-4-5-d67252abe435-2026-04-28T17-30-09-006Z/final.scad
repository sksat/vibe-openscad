// Butt Hinge Assembly - 180° Open State

// Parameters
leaf_length = 30;      // Y direction (along hinge axis)
leaf_width = 25;       // X direction (opening direction)
leaf_thickness = 2;
pin_diameter = 4;
pin_length = 32;
knuckle_outer_dia = 8;
knuckle_inner_dia = 4.6;
knuckle_width = 6;

// Module: Single leaf (flat plate)
module leaf(width, length, thickness) {
    cube([width, length, thickness], center=false);
}

// Module: Knuckle (cylindrical hinge element)
module knuckle() {
    difference() {
        cylinder(d=knuckle_outer_dia, h=knuckle_width, center=false, $fn=32);
        cylinder(d=knuckle_inner_dia, h=knuckle_width, center=false, $fn=32);
    }
}

// Module: Countersunk hole (M3)
module countersunk_hole() {
    union() {
        // Countersink: 6mm dia, 1mm deep
        cylinder(d=6, h=1, center=false, $fn=16);
        // Through hole: 3.2mm dia
        cylinder(d=3.2, h=leaf_thickness+2, center=false, $fn=16);
    }
}

// Module: Left leaf with knuckles and countersunk holes
module left_leaf_assembly() {
    difference() {
        union() {
            // Base plate (extends in negative X direction)
            translate([-(leaf_width), 0, 0])
                cube([leaf_width, leaf_length, leaf_thickness]);
            
            // Knuckles at Y = 0, 12, 24 mm (left leaf: positions 0, 2, 4)
            for (i = [0, 2, 4]) {
                y_pos = i * knuckle_width;
                translate([-knuckle_outer_dia/2, y_pos, 0])
                    knuckle();
            }
        }
        
        // Countersunk holes at Y = 2, 10, 18 mm (8mm spacing)
        for (y_pos = [2, 10, 18]) {
            translate([-(leaf_width/2), y_pos, -0.5])
                countersunk_hole();
        }
    }
}

// Module: Right leaf with knuckles and countersunk holes
module right_leaf_assembly() {
    difference() {
        union() {
            // Base plate (extends in positive X direction)
            cube([leaf_width, leaf_length, leaf_thickness]);
            
            // Knuckles at Y = 6, 18 mm (right leaf: positions 1, 3)
            for (i = [1, 3]) {
                y_pos = i * knuckle_width;
                translate([knuckle_outer_dia/2, y_pos, 0])
                    knuckle();
            }
        }
        
        // Countersunk holes at Y = 2, 10, 18 mm (8mm spacing)
        for (y_pos = [2, 10, 18]) {
            translate([leaf_width/2, y_pos, -0.5])
                countersunk_hole();
        }
    }
}

// Module: Pin shaft
module pin_shaft() {
    // Pin runs along Z axis from -1mm to 31mm (protrudes 1mm on each end)
    cylinder(d=pin_diameter, h=pin_length, center=false, $fn=32);
}

// Assembly - 180° open state
// Coordinate system:
// - Y axis: hinge axis direction (0-30mm along leaves)
// - X axis: opening direction (left leaf negative, right leaf positive)
// - Z axis: pin shaft axis

// Pin shaft: centered at X=0, Y direction from 0-30mm, Z from -1 to 31mm
translate([0, 0, -1])
    pin_shaft();

// Left leaf: extends in negative X, base at Z=0
translate([0, 0, 0])
    left_leaf_assembly();

// Right leaf: extends in positive X, base at Z=0 (180° open, same plane)
translate([0, 0, 0])
    right_leaf_assembly();