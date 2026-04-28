// L-bracket with countersunk holes

$fn = 64;

width    = 50;   // X
depth    = 40;   // Y (horizontal flange)
height   = 40;   // Z (vertical flange)
thk      = 3;    // plate thickness

hole_d   = 4.5;  // through hole
csk_d    = 8;    // countersink diameter
csk_h    = 2;    // countersink depth
edge_off = 10;   // distance from edge

// Hole X positions (symmetric on center line)
hx1 = width/2 - 10;
hx2 = width/2 + 10;

module countersunk_hole_z(z_outer_top) {
    // Hole drilled along Z axis. z_outer_top = top surface Z (outer face).
    // Through hole
    translate([0, 0, z_outer_top - thk - 0.1])
        cylinder(d = hole_d, h = thk + 0.2);
    // Countersink from outer (top) face going down
    translate([0, 0, z_outer_top - csk_h])
        cylinder(d = csk_d, h = csk_h + 0.01);
}

module countersunk_hole_y(y_outer_front) {
    // Hole drilled along Y axis. y_outer_front = outer face Y.
    translate([0, y_outer_front - thk - 0.1, 0])
        rotate([-90, 0, 0])
            cylinder(d = hole_d, h = thk + 0.2);
    translate([0, y_outer_front - csk_h, 0])
        rotate([-90, 0, 0])
            cylinder(d = csk_d, h = csk_h + 0.01);
}

difference() {
    union() {
        // Horizontal flange: top surface at Z=0, extends in +Y
        translate([0, 0, -thk])
            cube([width, depth, thk]);
        // Vertical flange: front surface at Y=0, extends in +Z
        translate([0, -thk, 0])
            cube([width, thk, height]);
    }

    // Horizontal flange holes (countersink on bottom = outer face)
    // Outer face is at Z = -thk; bolt head from below.
    // Use countersunk_hole_z with mirrored orientation: drill from bottom.
    for (x = [hx1, hx2]) {
        translate([x, depth - edge_off, 0]) {
            // Through hole
            translate([0, 0, -thk - 0.1])
                cylinder(d = hole_d, h = thk + 0.2);
            // Countersink on bottom (outer) face, opening downward
            translate([0, 0, -thk])
                cylinder(d1 = csk_d, d2 = csk_d, h = csk_h + 0.01);
        }
    }

    // Vertical flange holes (countersink on front = outer face at Y = -thk)
    for (x = [hx1, hx2]) {
        translate([x, 0, height - edge_off]) {
            // Through hole along Y
            translate([0, -thk - 0.1, 0])
                rotate([-90, 0, 0])
                    cylinder(d = hole_d, h = thk + 0.2);
            // Countersink on front face
            translate([0, -thk, 0])
                rotate([-90, 0, 0])
                    cylinder(d = csk_d, h = csk_h + 0.01);
        }
    }
}