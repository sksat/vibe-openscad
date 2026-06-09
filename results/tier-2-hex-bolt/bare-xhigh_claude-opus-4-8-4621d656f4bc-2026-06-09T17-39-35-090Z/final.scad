// M8 六角ボルト

// 寸法パラメータ
across_flats = 13;    // 対辺距離 (mm)
head_height  = 5.3;   // 頭部高さ (mm)
shank_dia    = 8;     // シャンク直径 (mm)
shank_len    = 30;    // シャンク長さ (mm)

$fn = 100;

module hex_bolt() {
    // 頭部:六角柱(底面が z=0、上方向へ伸ばす)
    // 対辺距離から外接円半径を算出
    head_r = across_flats / sqrt(3);
    cylinder(h = head_height, r = head_r, $fn = 6);

    // シャンク:z<0 側へ伸ばす
    translate([0, 0, -shank_len])
        cylinder(h = shank_len, d = shank_dia);
}

hex_bolt();