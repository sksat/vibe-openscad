// M8 六角ボルト
$fn = 100;

// 寸法
across_flats = 13;      // 対辺距離
head_height  = 5.3;     // 頭部高さ
shank_dia    = 8;       // シャンク直径
shank_len    = 30;      // シャンク長さ

// 対辺距離から外接円半径を計算
head_radius = across_flats / (2 * cos(30));

// 頭部(六角柱):底面が z=0、上面が z=head_height
translate([0, 0, head_height/2])
    cylinder(h = head_height, r = head_radius, center = true, $fn = 6);

// シャンク(円柱):z=0 から z<0 方向へ伸ばす
translate([0, 0, -shank_len])
    cylinder(h = shank_len, d = shank_dia, $fn = 100);