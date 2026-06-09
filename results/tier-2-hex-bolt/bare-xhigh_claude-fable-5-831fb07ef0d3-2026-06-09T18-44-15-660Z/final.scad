// M8 六角ボルト(ねじ山省略・簡易モデル)
// 頭部底面が z=0、シャンクは z<0 側へ伸びる

af      = 13;    // 頭部 対辺距離 (across-flats) [mm]
head_h  = 5.3;   // 頭部 高さ [mm]
shank_d = 8;     // シャンク 直径 [mm]
shank_l = 30;    // シャンク 長さ [mm]

$fn = 64;        // 円柱の滑らかさ

module hex_bolt() {
    // 頭部:六角柱(対辺距離から外接円半径を算出)
    cylinder(h = head_h, r = af / 2 / cos(30), $fn = 6);

    // シャンク:円柱(z = -shank_l から z = 0 まで)
    translate([0, 0, -shank_l])
        cylinder(h = shank_l, d = shank_d);
}

hex_bolt();