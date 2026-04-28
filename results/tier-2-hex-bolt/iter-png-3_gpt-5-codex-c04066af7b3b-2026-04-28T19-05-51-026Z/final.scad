af = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

module m8_hex_bolt() {
    union() {
        cylinder(h = head_height, r = af / sqrt(3), $fn = 6);
        translate([0, 0, -shank_length])
            cylinder(h = shank_length, r = shank_diameter / 2, $fn = 100);
    }
}

m8_hex_bolt();