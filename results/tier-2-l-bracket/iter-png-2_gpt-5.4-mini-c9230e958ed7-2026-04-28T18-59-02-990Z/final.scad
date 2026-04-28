$fn = 96;

// Dimensions
w = 50;      // flange width (X)
d = 40;      // horizontal flange depth (Y)
h = 40;      // vertical flange height (Z)
t = 3;       // plate thickness

// Hole parameters
through_d = 4.5;
csk_d = 8;
csk_depth = 2;
inset = 10;

// Countersunk through-hole along +Z, countersink on the +Z side
module csk_hole_z(hole_h) {
    union() {
        cylinder(h = hole_h, d = through_d);
        translate([0, 0, hole_h - csk_depth])
            cylinder(h = csk_depth, d1 = through_d, d2 = csk_d);
    }
}

// Countersunk through-hole along +Y, countersink on the +Y side
module csk_hole_y(hole_h) {
    rotate([-90, 0, 0])
        csk_hole_z(hole_h);
}

// Horizontal flange: lies in XY plane, thickness in Z
module horizontal_flange() {
    difference() {
        cube([w, d, t], center = false);

        for (x = [inset, w - inset]) {
            translate([x, d/2, 0])
                csk_hole_z(t);
        }
    }
}

// Vertical flange: lies in XZ plane, thickness in Y
module vertical_flange() {
    difference() {
        cube([w, t, h], center = false);

        for (x = [inset, w - inset]) {
            translate([x, t, h/2])
                csk_hole_y(t);
        }
    }
}

union() {
    horizontal_flange();
    vertical_flange();
}