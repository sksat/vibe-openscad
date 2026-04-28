module hex_bolt_m8() {
    // 六角形の対辺距離 13mm から、外接円の半径を計算
    // 対辺距離 = sqrt(3) * 外接円半径
    // 外接円半径 = 対辺距離 / sqrt(3)
    hex_radius = 13 / sqrt(3);
    
    // 頭部：六角柱
    cylinder(h = 5.3, r = hex_radius, $fn = 6);
    
    // シャンク：円柱（z < 0 側へ伸ばす）
    translate([0, 0, -30])
        cylinder(h = 30, r = 4, $fn = 32);
}

hex_bolt_m8();