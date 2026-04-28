// L-bracket with countersunk M4 holes
$fn = 64;

thickness = 3;
width     = 50;
length    = 40;          // depth of horizontal / height of vertical flange
hole_d    = 4.5;
sink_d    = 8;
sink_h    = 2;
xholes    = [10, width-10];

// Countersunk hole, axis along +Z, outer face at z = 0
module csunk(th = thickness) {
    // countersink
    cylinder(d = sink_d, h = sink_h, center = false);
    // through-hole (extra length to guarantee cut-through)
    translate([0, 0, sink_h])
        cylinder(d = hole_d, h = th + 1, center = false);
}

difference() {
    // -----------------------------------------------------------------
    // Solid bracket
    union() {
        // Horizontal flange (extends +Y, thickness in -Z)
        translate([0, 0, -thickness])
            cube([width, length, thickness], center = false);

        // Vertical flange (extends +Z, thickness in -Y)
        translate([0, -thickness, 0])
            cube([width, thickness, length], center = false);
    }

    // -----------------------------------------------------------------
    // Holes – horizontal flange (outer face at Z = -thickness)
    for (x = xholes)
        translate([x, length/2, -thickness])
            csunk();

    // Holes – vertical flange (outer face at Y = -thickness)
    for (x = xholes)
        translate([x, -thickness, length/2])
            rotate([90, 0, 0]) csunk();
}