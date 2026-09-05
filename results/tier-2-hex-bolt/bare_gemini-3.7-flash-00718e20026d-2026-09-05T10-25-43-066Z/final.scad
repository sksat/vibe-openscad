$fn = 64;

// 頭部 (対辺13mm, 高さ5.3mm)
// z = 0 から z = 5.3 へ配置
cylinder(h = 5.3, r = (13 / 2) / cos(30), $fn = 6);

// シャンク (直径8mm, 長さ30mm)
// z = 0 から z = -30 へ配置
translate([0, 0, -30])
    cylinder(h = 30, d = 8);