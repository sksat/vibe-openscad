// マグカップのパラメータ
outer_diameter = 80;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;
handle_radius = 12; // ハンドルのリングの半径

// 計算される値
inner_diameter = outer_diameter - (wall_thickness * 2);
inner_height = height - bottom_thickness;

// カップ本体
difference() {
    // 外側の円筒
    cylinder(h = height, r = outer_diameter / 2, $fn = 64);

    // 内側をくり抜く円筒
    translate([0, 0, bottom_thickness]) {
        cylinder(h = inner_height, r = inner_diameter / 2, $fn = 64);
    }
}

// 取手
translate([outer_diameter / 2, 0, height / 2]) { // カップの側面に移動し、中心高さに配置
    rotate([0, 90, 0]) { // 円筒の軸をX方向に回転
        difference() {
            // 外側のリング部分
            cylinder(h = wall_thickness + handle_radius * 2, r = handle_radius + wall_thickness, $fn = 64);
            // 内側をくり抜く部分
            cylinder(h = wall_thickness + handle_radius * 2, r = handle_radius, $fn = 64);
        }
    }
}