head_af = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

head_r = head_af / sqrt(3);

union() {
    cylinder(h = head_height, r = head_r, $fn = 6);
    translate([0, 0, -shank_length])
        cylinder(h = shank_length, d = shank_diameter, $fn = 64);
}