union() {
    translate([0, 0, -30])
        cylinder(h = 30, d = 8, $fn = 64);

    cylinder(h = 5.3, r = 13 / (2 * cos(30)), $fn = 6);
}