// M8 六角ボルト (ねじ山なし)

// 頭部: 対辺距離 13mm、高さ 5.3mm
// cylinder(fn=6)のrは内接円半径(対辺距離の半分)を指定する
head_across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

// 頭部: z=0 から z=5.3 まで配置
cylinder(r = (head_across_flats / 2) / cos(180/6), h = head_height, $fn = 6);

// シャンク: z=0 から z=-30 まで配置
translate([0, 0, -shank_length])
cylinder(r = shank_diameter / 2, h = shank_length, $fn = 64);