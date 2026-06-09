// M8 hex bolt (simplified, no threads)

// Parameters
across_flats = 13;      // 対辺距離 (mm)
head_height  = 5.3;     // 頭部高さ (mm)
shank_dia    = 8;       // シャンク直径 (mm)
shank_len    = 30;      // シャンク長さ (mm)

$fn = 100;

module hex_bolt() {
    // 頭部: 六角柱 (底面 z=0, 上面 z=head_height)
    // 対辺距離から外接円半径を計算
    r_head = across_flats / sqrt(3);
    cylinder(h = head_height, r = r_head, $fn = 6);

    // シャンク: z<0 側へ伸ばす
    translate([0, 0, -shank_len])
        cylinder(h = shank_len, d = shank_dia);
}

hex_bolt();