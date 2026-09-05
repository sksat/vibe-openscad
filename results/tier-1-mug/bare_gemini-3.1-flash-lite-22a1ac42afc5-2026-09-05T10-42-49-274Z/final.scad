$fn = 100;

// マグカップ本体
difference() {
    // 外形
    cylinder(h = 100, d = 80);
    
    // 内側のくり抜き
    translate([0, 0, 6])
    cylinder(h = 100, d = 80 - 4 * 2);
}

// 取手
translate([40 - 2, 50, 0]) {
    rotate([90, 0, 0]) {
        difference() {
            // 取手の外側
            torus(major_radius = 20, minor_radius = 6);
            // 取手の内側（指を通す穴）
            torus(major_radius = 20, minor_radius = 6 - 4);
        }
    }
}

// トーラス作成用モジュール
module torus(major_radius, minor_radius) {
    rotate_extrude()
    translate([major_radius, 0, 0])
    circle(r = minor_radius);
}