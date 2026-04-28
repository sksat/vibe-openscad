$fn = 96;

// Dimensions
w = 50;      // flange width
d = 40;      // horizontal flange depth
h = 40;      // vertical flange height
t = 3;       // thickness

// Hole parameters
through_d = 4.5;
csk_d = 8;
csk_depth = 2;
inset = 10;

// Countersunk hole cutout along +Z, with countersink on the top side
module csk_cut(hole_len) {
    union() {
        cylinder(h = hole_len, d = through_d);
        translate([0, 0, hole_len - csk_depth])
            cylinder(h = csk_depth, d1 = through_d, d2 = csk_d);
    }
}

// Horizontal flange: X width, Y depth, Z thickness
module horizontal_flange() {
    difference() {
        cube([w, d, t], center = false);

        for (x = [inset, w - inset]) {
            translate([x, d/2, 0])
                csk_cut(t);
        }
    }
}

// Vertical flange: X width, Y thickness, Z height
// Positioned so inner corner is at the origin and it extends in +Z.
// Countersink is on the outside face at Y = thickness side.
module vertical_flange() {
    difference() {
        cube([w, t, h], center = false);

        for (x = [inset, w - inset]) {
            translate([x, 0, h - t])
                rotate([180, 0, 0])  // make countersink face outward (+Y)
                    csk_cut(t);
        }
    }
}

union() {
    horizontal_flange();
    vertical_flange();
}