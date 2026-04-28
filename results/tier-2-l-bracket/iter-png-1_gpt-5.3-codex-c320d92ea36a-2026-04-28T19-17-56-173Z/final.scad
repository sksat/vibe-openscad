// L-bracket parameters
w = 50;          // width (X)
d = 40;          // horizontal depth (Y)
h = 40;          // vertical height (Z)
t = 3;           // thickness

// Hole parameters (M4 screw as specified)
through_d = 4.5; // through hole diameter
cs_d = 8;        // countersink seat diameter
cs_depth = 2;    // countersink seat depth

// Hole placement
edge_inset = 10; // from edge inward along width (X)
x_pos = [edge_inset, w - edge_inset];

$fn = 96;

difference() {
    union() {
        // Horizontal flange: 50 x 40, thickness 3, extends +Y from inner corner
        cube([w, d, t], center = false);

        // Vertical flange: 50 x 40, thickness 3, extends +Z from inner corner
        cube([w, t, h], center = false);
    }

    // Horizontal flange holes (centerline in Y, countersink on outer side +Z)
    for (x = x_pos) {
        // Through hole
        translate([x, d/2, -0.1])
            cylinder(d = through_d, h = t + 0.2);

        // Countersink seat (as cylindrical seat: Φ8 x 2)
        translate([x, d/2, t - cs_depth])
            cylinder(d = cs_d, h = cs_depth + 0.1);
    }

    // Vertical flange holes (centerline in Z, countersink on outer side +Y)
    for (x = x_pos) {
        // Through hole (axis along Y)
        translate([x, -0.1, h/2])
            rotate([-90, 0, 0])
                cylinder(d = through_d, h = t + 0.2);

        // Countersink seat (outer side +Y, depth into plate)
        translate([x, t - cs_depth, h/2])
            rotate([-90, 0, 0])
                cylinder(d = cs_d, h = cs_depth + 0.1);
    }
}