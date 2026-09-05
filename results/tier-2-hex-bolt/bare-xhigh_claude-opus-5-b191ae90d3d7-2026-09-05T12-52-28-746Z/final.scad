// M8 六角ボルト(ねじ山省略・シャンクは円柱)
// 頭部底面が z = 0、シャンクは -Z 方向へ

// ---- 寸法パラメータ ----
head_af     = 13;    // 頭部 対辺距離 (across-flats)
head_height = 5.3;   // 頭部 高さ
shank_dia   = 8;     // シャンク 直径 (M8)
shank_len   = 30;    // シャンク 長さ

$fn = 96;            // 円柱の分割数

// 対辺距離 -> 外接円半径
head_r = head_af / sqrt(3);

module hex_bolt_m8() {
    // 頭部(六角柱): z = 0 〜 head_height
    cylinder(h = head_height, r = head_r, $fn = 6);

    // シャンク(円柱): z = 0 〜 -shank_len
    translate([0, 0, -shank_len])
        cylinder(h = shank_len, d = shank_dia);
}

hex_bolt_m8();