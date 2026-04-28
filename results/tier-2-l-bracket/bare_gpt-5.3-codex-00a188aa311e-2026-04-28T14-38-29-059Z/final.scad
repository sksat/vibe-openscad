// L-bracket parameters
w = 50;          // width (X)
d = 40;          // horizontal depth (Y)
h = 40;          // vertical height (Z)
t = 3;           // thickness

// Hole parameters (M4 countersunk request as specified)
through_d = 4.5; // through hole diameter
cs_d = 8;        // countersink seat diameter
cs_depth = 2;    // countersink seat depth

// Hole placement
edge_inset = 10;             // from edge inward along length direction
x1 = edge_inset;
x2 = w - edge_inset;
y_center = d / 2;
z_center = h / 2;

$fn = 64;

difference() {
    union() {
        // Horizontal flange: extends +Y, thickness in +Z
        cube([w, d, t], center = false);

        // Vertical flange: extends +Z, thickness in +Y
        cube([w, t, h], center = false);
    }

    // ---- Horizontal flange holes (outer side is +Z) ----
    for (x = [x1, x2]) {
        // Through hole
        translate([x, y_center, -1])
            cylinder(d = through_d, h = t + 2);

        // Countersink seat (counterbore as specified: Φ8 x 2mm)
        translate([x, y_center, t - cs_depth])
            cylinder(d = cs_d, h = cs_depth + 0.01);
    }

    // ---- Vertical flange holes (outer side is +Y) ----
    for (x = [x1, x2]) {
        // Through hole (along Y)
        translate([x, -1, z_center])
            rotate([-90, 0, 0])
                cylinder(d = through_d, h = t + 2);

        // Countersink seat on outer side (+Y), depth into flange
        translate([x, t - cs_depth, z_center])
            rotate([-90, 0, 0])
                cylinder(d = cs_d, h = cs_depth + 0.01);
    }
}