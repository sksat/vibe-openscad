af = 13; // across-flats (mm)
head_h = 5.3; // head height (mm)
shank_d = 8; // shank diameter (mm)
shank_len = 30; // shank length (mm)

hex_R = af / sqrt(3);

union() {
    linear_extrude(height = head_h)
        circle(r = hex_R, $fn = 6);
    translate([0,0,-shank_len])
        cylinder(h = shank_len, r = shank_d/2, $fn = 64);
}