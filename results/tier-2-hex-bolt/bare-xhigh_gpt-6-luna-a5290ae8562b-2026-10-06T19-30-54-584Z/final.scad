union() {
    // 六角頭：対辺距離 13 mm、高さ 5.3 mm
    cylinder(h = 5.3, r = 13 / sqrt(3), $fn = 6);

    // シャンク：直径 8 mm、長さ 30 mm
    translate([0, 0, -30])
        cylinder(h = 30, d = 8);
}