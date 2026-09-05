// M8 hex bolt (ISO 4014 style, thread simplified as plain cylinder)

// ---- Parameters ----
head_af     = 13;    // across-flats width [mm]
head_height = 5.3;   // head height [mm]
shank_dia   = 8;     // shank diameter [mm]
shank_len   = 30;    // shank length [mm]
$fn         = 64;

// ---- Model ----
m8_hex_bolt();

module m8_hex_bolt() {
    // Head: hexagonal prism, bottom face at z = 0, extending to +Z
    hex_head(head_af, head_height);

    // Shank: cylinder extending to -Z from z = 0
    translate([0, 0, -shank_len])
        cylinder(h = shank_len, d = shank_dia);
}

module hex_head(across_flats, h) {
    // circumscribed circle diameter from across-flats distance
    cylinder(h = h, d = across_flats / cos(180 / 6), $fn = 6);
}