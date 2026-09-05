// M8 六角ボルト(ねじ山省略・シャンクは円柱)
// 頭部: 対辺距離 13mm / 高さ 5.3mm
// 軸部: φ8mm / 長さ 30mm

$fn = 64;

AF          = 13;      // 頭部 対辺距離 (across-flats)
HEAD_H      = 5.3;     // 頭部 高さ
SHANK_D     = 8;       // 軸部 直径
SHANK_L     = 30;      // 軸部 長さ

module hex_head(af, h) {
    // 六角柱: 対辺距離 af -> 外接円半径 af/sqrt(3)
    cylinder(h = h, r = af / sqrt(3), $fn = 6);
}

module shank(d, l) {
    translate([0, 0, -l])
        cylinder(h = l, d = d);
}

module m8_hex_bolt() {
    union() {
        // 頭部: z = 0 ～ 5.3
        hex_head(AF, HEAD_H);
        // 軸部: z = -30 ～ 0
        shank(SHANK_D, SHANK_L);
    }
}

m8_hex_bolt();