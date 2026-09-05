// M8 六角ボルト (ねじ山なし)

// 頭部: 対辺距離 13mm、高さ 5.3mm
// OpenSCADのcylinder(fn=6)は「外接円半径」を引数に取るため、
// 対辺距離(S)から半径(r)を求めるには r = S / sqrt(3) もしくは r = (S/2) / cos(30°) を用いる
head_across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

// 頭部: z=0 から z=5.3 まで配置
// 直径方向の補正: 半径 = (対辺距離 / 2) / cos(30°)
cylinder(r = (head_across_flats / 2) / cos(30), h = head_height, $fn = 6);

// シャンク: z=0 から z=-30 まで配置
translate([0, 0, -shank_length])
cylinder(r = shank_diameter / 2, h = shank_length, $fn = 64);