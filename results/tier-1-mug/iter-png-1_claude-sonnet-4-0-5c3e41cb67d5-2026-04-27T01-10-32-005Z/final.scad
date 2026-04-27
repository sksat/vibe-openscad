// マグカップのパラメータ
outer_diameter = 80;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;
handle_radius = 15;
handle_tube_radius = 3;

// 内径を計算
inner_diameter = outer_diameter - 2 * wall_thickness;
inner_height = height - bottom_thickness;

difference() {
    union() {
        // 外側のシリンダー（カップ本体）
        cylinder(h = height, d = outer_diameter, $fn = 100);
        
        // 取手 - トーラス形状で作成
        translate([outer_diameter/2 + handle_radius, 0, height/2]) {
            rotate([90, 0, 0]) {
                rotate_extrude($fn = 60) {
                    translate([handle_radius, 0, 0]) {
                        circle(r = handle_tube_radius, $fn = 20);
                    }
                }
            }
        }
        
        // 取手をカップ本体に接続するための部分
        hull() {
            // カップ側面の接続点
            translate([outer_diameter/2 - 2, 0, height/2 + handle_radius]) {
                sphere(r = handle_tube_radius, $fn = 20);
            }
            translate([outer_diameter/2 - 2, 0, height/2 - handle_radius]) {
                sphere(r = handle_tube_radius, $fn = 20);
            }
            // 取手側の接続点
            translate([outer_diameter/2 + handle_radius + handle_radius, 0, height/2 + handle_radius]) {
                sphere(r = handle_tube_radius, $fn = 20);
            }
            translate([outer_diameter/2 + handle_radius + handle_radius, 0, height/2 - handle_radius]) {
                sphere(r = handle_tube_radius, $fn = 20);
            }
        }
    }
    
    // 内側をくり抜き
    translate([0, 0, bottom_thickness]) {
        cylinder(h = inner_height + 1, d = inner_diameter, $fn = 100);
    }
}