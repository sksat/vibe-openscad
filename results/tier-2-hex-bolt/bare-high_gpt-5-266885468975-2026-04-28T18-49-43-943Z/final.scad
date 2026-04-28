// M8 Hex Bolt (simplified, no threads)
// Units: mm

across_flats = 13;   // Head across-flats
head_height  = 5.3;  // Head height
shank_diam   = 8;    // Shank diameter
shank_len    = 30;   // Shank length

function circ_d_from_af(af) = 2 * af / sqrt(3);

module hex_head(af, h) {
    // Hex head: bottom at z=0, top at z=h
    cylinder(d = circ_d_from_af(af), h = h, $fn = 6);
}

module shank(d, len) {
    // Shank: extends from z=-len to z=0
    translate([0, 0, -len])
        cylinder(d = d, h = len, $fn = 96);
}

union() {
    hex_head(across_flats, head_height);
    shank(shank_diam, shank_len);
}