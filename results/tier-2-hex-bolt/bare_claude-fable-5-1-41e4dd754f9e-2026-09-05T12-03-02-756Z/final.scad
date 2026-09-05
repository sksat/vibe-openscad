// M8 六角ボルト(ねじ山省略)
// 頭部底面が z=0、頭部は +Z 側、シャンクは -Z 側

$fn = 96;

// パラメータ
across_flats = 13;      // 対辺距離 [mm]
head_height  = 5.3;     // 頭部高さ [mm]
shank_d      = 8;       // シャンク直径 [mm]
shank_len    = 30;      // シャンク長さ [mm]

// 対辺距離 -> 外接円直径
across_corners = across_flats / cos(30);

module hex_head() {
    // 六角柱: z=0 から z=head_height
    cylinder(d = across_corners, h = head_height, $fn = 6);
}

module shank() {
    // 円柱: z=-shank_len から z=0
    translate([0, 0, -shank_len])
        cylinder(d = shank_d, h = shank_len);
}

module m8_hex_bolt() {
    union() {
        hex_head();
        shank();
    }
}

m8_hex_bolt();