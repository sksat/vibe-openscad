$fn = 100;

// カップ本体のパラメータ
outer_r = 40;     // 外径 80mm
height = 100;    // 高さ 100mm
wall_thick = 4;  // 肉厚 4mm
bottom_thick = 6;// 底の厚み 6mm

// 取手のパラメータ
handle_radius = 12;      // 取手の断面半径
handle_offset = 25;      // 取手の中心位置（カップ中心からの距離）
handle_center_z = height / 2; // 取手の高さ（中心）

module mug() {
    difference() {
        // カップの外形
        cylinder(r = outer_r, h = height);
        
        // 内側のくり抜き
        translate([0, 0, bottom_thick])
            cylinder(r = outer_r - wall_thick, h = height - bottom_thick + 0.1);
    }
}

module handle() {
    // カップの側面に接するように配置
    translate([outer_r - wall_thick, 0, handle_center_z])
        rotate([0, 90, 0])
            rotate_extrude(angle = 360)
                translate([handle_offset, 0, 0])
                    circle(r = handle_radius);
}

union() {
    mug();
    handle();
}