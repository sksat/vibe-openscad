// M8 六角ボルト(ねじ山省略・簡易形状)

// パラメータ
af      = 13;    // 頭部 対辺距離 (across-flats) [mm]
head_h  = 5.3;   // 頭部 高さ [mm]
shank_d = 8;     // シャンク直径 [mm]
shank_l = 30;    // シャンク長さ [mm]

$fn = 64;        // 円柱の滑らかさ

module m8_hex_bolt() {
    // 頭部:六角柱(底面が z=0、上方向へ)
    // $fn=6 の cylinder は頂点が半径 r 上に来るため、
    // 対辺距離 af に合わせるには r = (af/2) / cos(30°)
    cylinder(h = head_h, r = (af / 2) / cos(30), $fn = 6);

    // シャンク:円柱(z=0 から z<0 側へ伸びる)
    translate([0, 0, -shank_l])
        cylinder(h = shank_l, d = shank_d);
}

m8_hex_bolt();