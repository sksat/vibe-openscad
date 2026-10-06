af = 13;
head_h = 5.3;
shank_d = 8;
shank_l = 30;

union() {
    cylinder(h = head_h, d = 2 * af / sqrt(3), $fn = 6);

    translate([0, 0, -shank_l])
        cylinder(h = shank_l, d = shank_d, $fn = 100);
}