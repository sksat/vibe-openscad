// M8 hex bolt (ISO 4014 style, threads omitted)

// ---- Parameters ----
head_af     = 13;    // across-flats [mm]
head_height = 5.3;   // head height [mm]
shank_dia   = 8;     // shank diameter [mm]
shank_len   = 30;    // shank length [mm]

$fn = 120;

// ---- Model ----
module hex_head(af, h) {
    // circumscribed-circle diameter from across-flats
    cylinder(h = h, d = af / cos(180 / 6), $fn = 6);
}

module m8_bolt() {
    // head: bottom face at z = 0, extends to +Z
    hex_head(head_af, head_height);

    // shank: extends to -Z
    translate([0, 0, -shank_len])
        cylinder(h = shank_len, d = shank_dia);
}

m8_bolt();