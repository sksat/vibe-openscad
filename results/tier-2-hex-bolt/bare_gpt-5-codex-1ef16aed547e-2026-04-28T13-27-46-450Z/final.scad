AF = 13;
head_height = 5.3;
shank_length = 30;
shank_diameter = 8;

module hex_bolt() {
    union() {
        cylinder(h = head_height, r = AF / (2 * cos(30)), $fn = 6);
        translate([0, 0, -shank_length])
            cylinder(h = shank_length, r = shank_diameter / 2, $fn = 64);
    }
}

hex_bolt();