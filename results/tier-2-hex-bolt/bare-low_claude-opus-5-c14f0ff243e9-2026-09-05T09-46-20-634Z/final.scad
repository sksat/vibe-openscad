// M8 hex bolt (thread omitted, plain cylindrical shank)

// --- Parameters ---
head_af     = 13;    // across-flats [mm]
head_height = 5.3;   // head height [mm]
shank_dia   = 8;     // shank diameter [mm]
shank_len   = 30;    // shank length [mm]

$fn = 96;

module hex_bolt_m8() {
    // Head: hexagonal prism, bottom face at z = 0, extends to +Z
    cylinder(h = head_height, r = head_af / (2 * cos(30)), $fn = 6);

    // Shank: extends from z = 0 to z = -shank_len
    translate([0, 0, -shank_len])
        cylinder(h = shank_len, d = shank_dia);
}

hex_bolt_m8();