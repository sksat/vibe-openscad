// マグカップのパラメータ
outer_diameter = 80;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;
handle_outer_radius = 18;  // 取手の外径を大きく
handle_tube_radius = 4;    // 取手の太さを少し太く

// 内径を計算
inner_diameter = outer_diameter - 2 * wall_thickness;
inner_height = height - bottom_thickness;

difference() {
    union() {
        // 外側のシリンダー（カップ本体）
        cylinder(h = height, d = outer_diameter, $fn = 100);
        
        // 取手をカップ本体に接続するための部分
        translate([outer_diameter/2, 0, height/2]) {
            rotate([90, 0, 0]) {
                hull() {
                    // カップ側の接続点
                    translate([0, 0, 0])
                        cylinder(h = handle_tube_radius * 2, d = handle_tube_radius * 2, center = true, $fn = 20);
                    // 取手の内側接続点
                    translate([handle_outer_radius - handle_tube_radius, 0, 0])
                        cylinder(h = handle_tube_radius * 2, d = handle_tube_radius * 2, center = true, $fn = 20);
                }
            }
        }
        
        // リング状の取手
        translate([outer_diameter/2 + handle_outer_radius - handle_tube_radius, 0, height/2]) {
            rotate([90, 0, 0]) {
                rotate_extrude($fn = 60) {
                    translate([handle_outer_radius, 0, 0]) {
                        circle(r = handle_tube_radius, $fn = 20);
                    }
                }
            }
        }
    }
    
    // 内側をくり抜き
    translate([0, 0, bottom_thickness]) {
        cylinder(h = inner_height + 1, d = inner_diameter, $fn = 100);
    }
}