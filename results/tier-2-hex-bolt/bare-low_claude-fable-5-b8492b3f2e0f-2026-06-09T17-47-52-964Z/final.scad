$fn = 64;

af = 13;          // 対辺距離
head_h = 5.3;     // 頭部高さ
shank_d = 8;      // シャンク直径
shank_l = 30;     // シャンク長さ

// 頭部(六角柱): 対辺距離から外接円半径に換算
cylinder(h = head_h, r = af / 2 / cos(30), $fn = 6);

// シャンク: z<0 側へ
translate([0, 0, -shank_l])
    cylinder(h = shank_l, d = shank_d);