$fn = 64;

// 頭部 (対辺13mm, 高さ5.3mm)
cylinder(r = (13 / 2) / cos(30), h = 5.3, $fn = 6);

// シャンク (直径8mm, 長さ30mm)
translate([0, 0, -30])
    cylinder(d = 8, h = 30);