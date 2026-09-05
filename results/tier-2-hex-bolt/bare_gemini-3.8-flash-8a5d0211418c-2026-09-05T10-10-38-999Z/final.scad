$fn = 60;

// シャンク（軸部）: 直径 8mm、長さ 30mm、z < 0 側へ
translate([0, 0, -30])
    cylinder(h = 30, d = 8);

// 頭部: 対辺距離 13mm、高さ 5.3mm、z >= 0 側へ
linear_extrude(height = 5.3)
    circle(r = (13 / 2) / cos(30), $fn = 6);