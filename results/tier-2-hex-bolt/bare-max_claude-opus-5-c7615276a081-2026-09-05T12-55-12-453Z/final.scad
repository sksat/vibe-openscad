// M8 hex bolt (ISO 4014 style, simplified: unthreaded cylindrical shank)
// Head: hexagonal prism, across-flats 13 mm, height 5.3 mm
// Shank: diameter 8 mm, length 30 mm
// Axis: +Z. Head bottom face at z = 0, shank extends into z < 0.

$fn = 100;

// ---- Parameters ----------------------------------------------------
head_af     = 13;    // across-flats (対辺距離) [mm]
head_height = 5.3;   // 頭部高さ [mm]
shank_dia   = 8;     // シャンク直径 [mm]
shank_len   = 30;    // シャンク長さ [mm]

// ---- Modules -------------------------------------------------------
module hex_head(across_flats, h) {
    // circumscribed circle diameter from across-flats
    cylinder(h = h, d = across_flats / cos(30), $fn = 6);
}

module shank(d, l) {
    translate([0, 0, -l])
        cylinder(h = l, d = d);
}

module m8_hex_bolt() {
    union() {
        hex_head(head_af, head_height);
        shank(shank_dia, shank_len);
    }
}

// ---- Render --------------------------------------------------------
m8_hex_bolt();