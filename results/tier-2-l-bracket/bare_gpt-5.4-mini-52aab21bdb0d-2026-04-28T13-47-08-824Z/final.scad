// L-bracket with countersunk holes
// Units: mm

$fn = 96;

flange_w = 50;
horiz_d  = 40;
vert_h   = 40;
thickness = 3;

// Hole parameters
hole_d = 4.5;
csk_d  = 8;
csk_h  = 2;
edge_inset = 10;

// Geometry helpers
module countersunk_hole(total_thickness, thru_d, csk_d, csk_h) {
    union() {
        cylinder(h = total_thickness, d = thru_d);
        translate([0, 0, total_thickness - csk_h])
            cylinder(h = csk_h, d1 = thru_d, d2 = csk_d);
    }
}

module horizontal_flange() {
    difference() {
        cube([flange_w, horiz_d, thickness], center = false);

        for (x = [edge_inset, flange_w - edge_inset]) {
            translate([x, horiz_d/2, thickness])
                rotate([180, 0, 0])
                    countersunk_hole(thickness, hole_d, csk_d, csk_h);
        }
    }
}

module vertical_flange() {
    difference() {
        cube([flange_w, thickness, vert_h], center = false);

        for (x = [edge_inset, flange_w - edge_inset]) {
            translate([x, thickness/2, vert_h])
                rotate([180, 0, 0])
                    countersunk_hole(thickness, hole_d, csk_d, csk_h);
        }
    }
}

union() {
    horizontal_flange();
    vertical_flange();
}