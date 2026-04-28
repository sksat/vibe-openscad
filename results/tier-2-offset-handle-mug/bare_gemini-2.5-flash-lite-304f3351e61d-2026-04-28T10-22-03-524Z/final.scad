// マグカップのパラメータ
mug_outer_diameter = 80;
mug_wall_thickness = 5;
mug_height = 90;
mug_bottom_thickness = 6;

// 取手のパラメータ
handle_inner_height = 30;
handle_inner_width = 25;
handle_thickness = 8; // 本体との接続部を考慮した厚み

// マグ本体の計算
mug_outer_radius = mug_outer_diameter / 2;
mug_inner_radius = mug_outer_radius - mug_wall_thickness;
mug_body_height = mug_height - mug_bottom_thickness;

// マグ本体の作成
module mug_body() {
    difference() {
        // 外側の円筒
        cylinder(h = mug_height, r = mug_outer_radius, $fn = 100);
        // 内側の円筒 (飲み物用空間)
        translate([0, 0, mug_bottom_thickness])
            cylinder(h = mug_body_height, r = mug_inner_radius, $fn = 100);
    }
}

// 取手の作成
module mug_handle() {
    // 取手の中心位置をマグの高さの中央付近に設定
    handle_center_z = mug_height / 2;

    // 取手の外側の半円の半径
    handle_outer_radius = mug_inner_width / 2 + handle_thickness;
    // 取手の内側の半円の半径
    handle_inner_radius = mug_inner_width / 2;

    // 取手の幅 (本体との接続部を含む)
    handle_width = mug_outer_radius + handle_thickness;

    // 取手の形状を定義
    module handle_shape() {
        // D字形状の外側半円
        intersection() {
            cylinder(h = handle_thickness, r = handle_outer_radius, $fn = 100);
            translate([0, 0, -handle_thickness/2])
                cube([handle_outer_radius*2, handle_outer_radius*2, handle_thickness*2], center=true);
        }
        // D字形状の内側直線部分 (くり抜き用)
        translate([handle_inner_radius, 0, 0])
            cube([handle_width - handle_inner_radius, handle_inner_width, handle_thickness], center=true);
    }

    // 本体に接続する部分の形状
    module connection_part() {
        cylinder(h = handle_thickness, r1 = mug_outer_radius, r2 = mug_outer_radius, $fn = 100);
    }

    // 取手の作成と配置
    rotate([0, 90, 0]) { // X軸方向に回転させて +X 軸方向に向ける
        translate([mug_outer_radius + handle_thickness / 2, 0, handle_center_z]) {
            difference() {
                // 外側の形状
                union() {
                    // 半円部分
                    rotate([0, 0, 90])
                        cylinder(h = handle_thickness, r = handle_outer_radius, $fn = 100);
                    // 直線部分 (半円と繋がる)
                    translate([-handle_outer_radius, -handle_outer_radius, 0])
                        cube([handle_outer_radius, handle_outer_radius*2, handle_thickness], center=true);
                }
                // 内側のくり抜き
                translate([handle_inner_radius, 0, 0])
                    cylinder(h = handle_thickness, r = handle_inner_radius, $fn = 100);
                // 内側の直線部分 (指が入る空間)
                translate([handle_inner_radius + handle_inner_width/2, 0, 0])
                    cube([handle_inner_width, handle_inner_height, handle_thickness], center=true);
            }
        }
    }
}

// マグカップ全体を作成
union() {
    mug_body();
    mug_handle();
}