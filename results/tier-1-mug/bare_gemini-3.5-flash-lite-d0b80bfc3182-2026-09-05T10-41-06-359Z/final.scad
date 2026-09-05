// マグカップのパラメータ
outer_diameter = 80;
outer_radius = outer_diameter / 2; // 40mm
height = 100;
wall_thickness = 4;
bottom_thickness = 6;

// 取手のパラメータ
handle_outer_radius = 12;
handle_thickness = 8; // 取手の太さ（パイプの断面の半径）
handle_radius = handle_outer_radius - handle_thickness; // 取手の中心軌道の半径
handle_z = height / 2; // カップの中心高さ

// 解像度の設定
$fn = 100;

module mug() {
    // 1. メインボディと取手の結合
    union() {
        // カップ本体
        difference() {
            // 外側
            cylinder(h = height, r = outer_radius);
            
            // 内側（くり抜き）
            translate([0, 0, bottom_thickness])
                cylinder(h = height - bottom_thickness + 1, r = outer_radius - wall_thickness);
        }
        
        // 取手（リング状）
        // カップの側面から外側に飛び出すように配置
        translate([outer_radius + handle_radius - wall_thickness, 0, handle_z])
            rotate([0, 90, 0])
                rotate_extrude()
                    translate([handle_radius, 0, 0])
                        circle(r = handle_thickness);
    }
}

mug();