// Butt Hinge Assembly - 180° Open State (Corrected)

// Parameters
leaf_length = 30;      // Y direction (along hinge axis)
leaf_width = 25;       // X direction (opening direction)
leaf_thickness = 2;
pin_diameter = 4;
pin_length = 32;
knuckle_outer_dia = 8;
knuckle_inner_dia = 4.6;
knuckle_length = 6;    // Height along Z axis

// Module: Knuckle (cylindrical hinge element)
module knuckle() {
    difference() {
        cylinder(d=knuckle_outer_dia, h=knuckle_length, center=false, $fn=32);
        cylinder(d=knuckle_inner_dia, h=knuckle_length, center=false, $fn=32);
    }
}

// Module: Countersunk hole (M3)
module countersunk_hole() {
    // Countersink: 6mm dia (top), 3.2mm dia (bottom), 1mm deep with taper
    translate([0, 0, -0.5]) {
        cylinder(d1=6, d2=3.2, h=1, center=false, $fn=16);
        cylinder(d=3.2, h=leaf_thickness+1, center=false, $fn=16);
    }
}

// Module: Left leaf with knuckles and countersunk holes
module left_leaf_assembly() {
    difference() {
        union() {
            // Base plate (extends in negative X direction)
            translate([-(leaf_width), 0, 0])
                cube([leaf_width, leaf_length, leaf_thickness]);
            
            // Knuckles at Y = 0, 12, 24 mm (positions 0, 2, 4 of 5 divisions)
            for (i = [0, 2, 4]) {
                y_pos = i * knuckle_length;
                translate([-knuckle_outer_dia/2, y_pos, -knuckle_length])
                    knuckle();
            }
        }
        
        // Countersunk holes at Y = 2, 10, 18 mm (8mm spacing)
        for (y_pos = [2, 10, 18]) {
            translate([-(leaf_width/2), y_pos, leaf_thickness])
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
            
            // Knuckles at Y = 6, 18 mm (positions 1, 3 of 5 divisions)
            for (i = [1, 3]) {
                y_pos = i * knuckle_length;
                translate([knuckle_outer_dia/2, y_pos, -knuckle_length])
                    knuckle();
            }
        }
        
        // Countersunk holes at Y = 2, 10, 18 mm (8mm spacing)
        for (y_pos = [2, 10, 18]) {
            translate([leaf_width/2, y_pos, leaf_thickness])
                countersunk_hole();
        }
    }
}

// Module: Pin shaft
module pin_shaft() {
    cylinder(d=pin_diameter, h=pin_length, center=false, $fn=32);
}

// Assembly - 180° open state
// Pin shaft: centered at X=0, Y=0 to 30mm, Z=-1 to 31mm
translate([0, 0, -1])
    pin_shaft();

// Left leaf: extends in negative X, base at Z=0
translate([0, 0, 0])
    left_leaf_assembly();

// Right leaf: extends in positive X, base at Z=0 (180° open, same plane)
translate([0, 0, 0])
    right_leaf_assembly();