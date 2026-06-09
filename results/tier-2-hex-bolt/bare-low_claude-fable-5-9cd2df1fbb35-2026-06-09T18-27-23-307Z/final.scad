// M8 六角ボルト(ねじ山省略)
$fn = 64;

af = 13;          // 対辺距離
head_h = 5.3;     // 頭部高さ
shank_d = 8;      // シャンク直径
shank_l = 30;     // シャンク長さ

// 頭部(六角柱): 底面が z=0
cylinder(h = head_h, d = af / cos(30), $fn = 6);

// シャンク: z<0 方向へ
translate([0, 0, -shank_l])
    cylinder(h = shank_l, d = shank_d);