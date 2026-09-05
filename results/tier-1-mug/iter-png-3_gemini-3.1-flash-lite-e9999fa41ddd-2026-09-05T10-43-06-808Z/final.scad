$fn = 100;

// マグカップ本体
union() {
    difference() {
        // 外形: 直径80mm, 高さ100mm
        cylinder(h = 100, d = 80);
        
        // 内側のくり抜き: 底面厚6mm, 側面厚4mm
        translate([0, 0, 6])
        cylinder(h = 100, d = 80 - 4 * 2);
    }

    // 取手: 外径方向に飛び出す半径12mmの断面を持つリング
    // リングの中心位置を調整し、カップの外壁に接続
    translate([40 - 2, 0, 50]) {
        rotate([0, 90, 0]) {
            // 半径12mmのトーラス（major_radiusは中心軸からの距離）
            // minor_radiusを12mmに設定
            torus(major_radius = 14, minor_radius = 6);
        }
    }
}

// トーラス作成用モジュール
module torus(major_radius, minor_radius) {
    rotate_extrude()
    translate([major_radius, 0, 0])
    circle(r = minor_radius);
}