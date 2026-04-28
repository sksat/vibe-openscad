// openscad
$fn = 64;

// Parameters
w = 50;             // width (X)
len = 40;           // flange length (Y for horizontal, Z for vertical)
t = 3;              // thickness
hole_d = 4.5;       // through hole diameter for M4
cs_d = 8;           // countersink seat diameter
cs_depth = 2;       // countersink depth

// Hole X positions: 10mm from each lateral edge (symmetric)
hole_x = [10, w - 10];

// Centers along the face midline
h_y = len/2;    // horizontal flange holes: Y coordinate
v_z = len/2;    // vertical flange holes: Z coordinate

module bracket() {
    // Horizontal flange: X:0..w, Y:0..len, Z:0..t
    translate([0,0,0]) cube([w, len, t], center=false);
    // Vertical flange: X:0..w, Y:0..t, Z:0..len
    translate([0,0,0]) cube([w, t, len], center=false);
}

module subtract_holes() {
    // Horizontal flange holes (axis Z), countersink on outer side (+Z)
    for (x = hole_x) {
        // through hole (centered in thickness)
        translate([x, h_y, t/2]) cylinder(h=100, r=hole_d/2, center=true);
        // countersink pocket from outer face (+Z), depth cs_depth
        translate([x, h_y, t - cs_depth/2]) cylinder(h=cs_depth, r=cs_d/2, center=true);
    }

    // Vertical flange holes (axis Y), countersink on outer side (+Y)
    for (x = hole_x) {
        // through hole (axis along Y), center at Y = t/2
        translate([x, t/2, v_z]) rotate([90,0,0]) cylinder(h=100, r=hole_d/2, center=true);
        // countersink pocket from outer face (+Y), depth cs_depth (axis along Y)
        translate([x, t - cs_depth/2, v_z]) rotate([90,0,0]) cylinder(h=cs_depth, r=cs_d/2, center=true);
    }
}

// Final part: union of flanges minus holes/countersinks
difference() {
    bracket();
    subtract_holes();
}