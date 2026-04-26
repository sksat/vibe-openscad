$fn = 100;

// マグカップ本体の作成
difference() {
    // 外側の円柱 (外径 80mm -> 半径 40mm, 高さ 100mm)
    cylinder(h = 100, r = 40);

    // 内側のくり抜き (肉厚 4mm -> 半径 36mm, 底面の厚み 6mm)
    translate([0, 0, 6])
        cylinder(h = 100, r = 36);
}

// 取手 (リング状) の作成
translate([50, 0, 50]) // カップの中心高さ(50mm)かつ外側に配置
rotate([90, 0, 0])      // リングを垂直に立たせる
rotate_extrude()
translate([12, 0, 0])   // 取手の半径 12mm
circle(r = 4);          // 取手自体の太さ (半径 4mm)