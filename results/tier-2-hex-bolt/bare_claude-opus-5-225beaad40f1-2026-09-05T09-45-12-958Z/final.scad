// M8 hex bolt (ISO 4017 style, threads omitted)
// Head: hex prism, across-flats 13 mm, height 5.3 mm
// Shank: cylinder, d = 8 mm, length 30 mm
// Head bottom face at z = 0, shank extends toward -Z

$fn = 64;

af       = 13;      // across-flats of head
head_h   = 5.3;     // head height
shank_d  = 8;       // shank diameter
shank_l  = 30;      // shank length

module hex_prism(across_flats, h) {
    // circumscribed radius from across-flats distance
    cylinder(h = h, r = across_flats / sqrt(3), $fn = 6);
}

module m8_hex_bolt() {
    // head: sits on top of z = 0
    hex_prism(af, head_h);

    // shank: extends downward from z = 0
    translate([0, 0, -shank_l])
        cylinder(h = shank_l, d = shank_d);
}

m8_hex_bolt();