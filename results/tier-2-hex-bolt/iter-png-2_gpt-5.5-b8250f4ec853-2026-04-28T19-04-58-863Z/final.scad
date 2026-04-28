$fn = 96;

union() {
    cylinder(h = 5.3, r = 13 / (2 * cos(30)), $fn = 6);
    translate([0, 0, -30])
        cylinder(h = 30, d = 8);
}