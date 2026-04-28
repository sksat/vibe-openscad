// L-bracket with countersunk M4 holes
difference() {
    // bracket body
    union() {
        // horizontal flange (X × Y × Z)
        cube([50, 40, 3]);
        // vertical flange (X × Y × Z), thickness along Y
        cube([50, 3, 40]);
    }

    // horizontal flange holes (axis along Z)
    for (x = [10, 40]) {
        // through-hole Ø4.5
        translate([x, 20, 0])
            cylinder(d = 4.5, h = 3, center = false);
        // countersink Ø8 × depth 2 from top (+Z)
        translate([x, 20, 1])
            cylinder(d = 8, h = 2, center = false);
    }

    // vertical flange holes (axis along Y)
    for (x = [10, 40]) {
        // through-hole Ø4.5
        translate([x, 0, 20])
            rotate([-90, 0, 0])
                cylinder(d = 4.5, h = 3, center = false);
        // countersink Ø8 × depth 2 from outer side (+Y)
        translate([x, 1, 20])
            rotate([-90, 0, 0])
                cylinder(d = 8, h = 2, center = false);
    }
}