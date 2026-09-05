// M8 hex bolt (thread omitted, plain cylindrical shank)

$fn = 64;

head_across_flats = 13;   // 対辺距離
head_height       = 5.3;  // 頭部高さ
shank_diameter    = 8;    // シャンク径
shank_length      = 30;   // シャンク長

module hex_head(af, h) {
    // 六角柱: 対辺距離 af (外接円直径 = af / cos(30))
    cylinder(h = h, d = af / cos(180 / 6), $fn = 6);
}

module m8_bolt() {
    // 頭部: 底面 z=0、上方 +Z へ
    hex_head(head_across_flats, head_height);

    // シャンク: z=0 から -Z 方向へ
    translate([0, 0, -shank_length])
        cylinder(h = shank_length, d = shank_diameter);
}

m8_bolt();