// L-bracket with countersunk holes
// Units: mm

$fn = 96;

t = 3;          // thickness
w = 50;         // width
h = 40;         // height
d = 40;         // depth

hole_d = 4.5;   // through hole diameter
csk_d  = 8;     // countersink diameter
csk_depth = 2;  // countersink depth
hole_offset = 10;

module countersunk_hole_z(thickness, through_d, csk_d, csk_depth) {
    union() {
        cylinder(h = thickness + 0.2, d = through_d, center = false);
        translate([0, 0, thickness - csk_depth])
            cylinder(h = csk_depth + 0.2, d1 = through_d, d2 = csk_d, center = false);
    }
}

module countersunk_hole_y(thickness, through_d, csk_d, csk_depth) {
    rotate([-90, 0, 0])
        union() {
            cylinder(h = thickness + 0.2, d = through_d, center = false);
            translate([0, 0, thickness - csk_depth])
                cylinder(h = csk_depth + 0.2, d1 = through_d, d2 = csk_d, center = false);
        }
}

difference() {
    union() {
        // Vertical flange: X width, Z height, thickness in Y
        translate([-w/2, 0, 0])
            cube([w, t, h]);

        // Horizontal flange: X width, Y depth, thickness in Z
        translate([-w/2, 0, 0])
            cube([w, d, t]);
    }

    // Horizontal flange holes: countersink on bottom side (-Z), holes through Z
    for (x = [-w/2 + hole_offset, w/2 - hole_offset]) {
        translate([x, 20, 0])
            countersunk_hole_z(t, hole_d, csk_d, csk_depth);
    }

    // Vertical flange holes: countersink on outside side (+Y), holes through Y
    for (x = [-w/2 + hole_offset, w/2 - hole_offset]) {
        translate([x, t, 20])
            rotate([180, 0, 0])
                countersunk_hole_y(t, hole_d, csk_d, csk_depth);
    }
}