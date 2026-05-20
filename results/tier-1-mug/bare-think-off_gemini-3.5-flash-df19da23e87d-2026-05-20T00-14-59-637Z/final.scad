$fn = 100;

// パラメータ設定
outer_diameter = 80;
total_height = 100;
wall_thickness = 4;
bottom_thickness = 6;

handle_inner_radius = 12; // 指を通す部分の半径
handle_thickness = 8;     // 取っ手の輪の太さ
handle_outer_radius = handle_inner_radius + handle_thickness;

difference() {
    union() {
        // カップ外側
        cylinder(d = outer_diameter, h = total_height);

        // 取っ手 (中心高さに配置)
        translate([outer_diameter / 2 - wall_thickness, 0, total_height / 2]) {
            rotate([90, 0, 0]) {
                // ドーナツ形状 (トーラス)
                rotate_extrude() {
                    translate([handle_outer_radius, 0, 0]) {
                        circle(r = handle_thickness / 2);
                    }
                }
            }
        }
    }

    // カップ内側のくり抜き
    translate([0, 0, bottom_thickness]) {
        cylinder(d = outer_diameter - (wall_thickness * 2), h = total_height);
    }
}