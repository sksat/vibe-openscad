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
                leaf(leaf_width, leaf_length, leaf_thickness);
            
            // Knuckles at Y = 0, 12, 24 mm (left leaf: outer 2 + center 1)
            for (y_pos = [0, 12, 24]) {
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
            leaf(leaf_width, leaf_length, leaf_thickness);
            
            // Knuckles at Y = 6, 18 mm (right leaf: intermediate 2)
            for (y_pos = [6, 18]) {
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
    cylinder(d=pin_diameter, h=pin_length, center=false, $fn=32);
}

// Assembly - 180° open state
// Pin shaft centered at X=0, running along Y axis from Y=0 to Y=32
translate([0, 0, leaf_thickness])
    pin_shaft();

// Left leaf: plate extends in negative X, centered at origin
translate([0, 0, 0])
    left_leaf_assembly();

// Right leaf: plate extends in positive X, centered at origin, at same Z height
translate([0, 0, 0])
    right_leaf_assembly();