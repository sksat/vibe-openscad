// M8 六角ボルト

// パラメータ
head_across_flats = 13;  // 対辺距離
head_height = 5.3;        // 頭部の高さ
shank_diameter = 8;       // シャンク直径
shank_length = 30;        // シャンク長さ

// 六角柱の頭部
translate([0, 0, 0])
    cylinder(d = head_across_flats / cos(30), h = head_height, $fn = 6);

// シャンク（円柱）
translate([0, 0, -shank_length])
    cylinder(d = shank_diameter, h = shank_length, $fn = 50);