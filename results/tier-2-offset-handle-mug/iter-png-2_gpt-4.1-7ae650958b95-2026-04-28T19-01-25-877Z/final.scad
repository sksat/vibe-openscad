// マグ本体パラメータ
mug_outer_diameter = 80;    // mm
mug_inner_diameter = 70;    // mm
mug_height = 90;            // mm
mug_wall_thickness = 5;     // mm
mug_bottom_thickness = 6;   // mm

// 取手パラメータ
handle_inner_height = 30;    // mm
handle_inner_width  = 25;    // mm
handle_thickness    = 12;    // mm (グリップ断面の太さ)

// マグ座標
mug_radius = mug_outer_diameter / 2;
mug_inner_radius = mug_inner_diameter / 2;

// 取手座標・D字生成用
handle_profile_top    = handle_inner_height / 2;
handle_profile_bottom = -handle_inner_height / 2;
handle_profile_right  = mug_radius + handle_inner_width;
handle_profile_left   = mug_radius;

module mug_body() {
    difference() {
        // 外側
        cylinder(h = mug_height, r = mug_radius, $fn = 128);
        // 内容器
        translate([0, 0, mug_bottom_thickness])
            cylinder(h = mug_height - mug_bottom_thickness, r = mug_inner_radius, $fn = 128);
    }
}

module d_handle() {
    // D字2Dプロファイル作成
    // 縦方向がhandle_inner_heightの長方形＋右に半円
    handle_center_z = mug_height / 2;
    translate([0, 0, handle_center_z])  // マグ中央高さに配置
    rotate([90,0,0])
    translate([0, 0, 0]) {
        rotate_extrude(angle=180, $fn=64)
            translate([mug_radius + handle_inner_width, 0, 0])
                circle(handle_inner_height/2, $fn=64);

        // ハンドルの直線部分(マグ側に接するストレート部分)
        hull() {
            translate([mug_radius, handle_profile_top]) circle(handle_thickness/2, $fn=32);
            translate([mug_radius, handle_profile_bottom]) circle(handle_thickness/2, $fn=32);
        }
    }
}

union() {
    mug_body();
    // 取手を-90度回転して+X側に設置し、太さ分拡げる
    rotate([0,0,0])
        d_handle();
}