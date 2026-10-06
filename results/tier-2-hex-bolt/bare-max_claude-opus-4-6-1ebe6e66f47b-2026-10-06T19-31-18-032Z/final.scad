$fn = 64;

// Parameters
af = 13;           // across-flats (対辺距離)
head_h = 5.3;      // 頭部高さ
shank_d = 8;       // シャンク直径
shank_l = 30;      // シャンク長さ

// Hex head: bottom face at z=0, extending upward
translate([0, 0, head_h / 2])
    rotate([0, 0, 30])
        cylinder(d = af / cos(30), h = head_h, center = true, $fn = 6);

// Shank: extending downward from z=0
translate([0, 0, -shank_l / 2])
    cylinder(d = shank_d, h = shank_l, center = true);