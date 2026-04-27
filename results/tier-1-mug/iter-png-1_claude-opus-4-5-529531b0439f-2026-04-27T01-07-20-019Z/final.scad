// マグカップのパラメータ
outer_diameter = 80;
outer_radius = outer_diameter / 2;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;

inner_radius = outer_radius - wall_thickness;
inner_height = height - bottom_thickness;

// 取手のパラメータ
handle_ring_radius = 12;  // 取手リングの半径
handle_tube_radius = 5;   // 取手の太さ（断面半径）
handle_center_height = height / 2;  // 取手の中心高さ

module cup_body() {
    difference() {
        // 外側の円柱
        cylinder(r = outer_radius, h = height, $fn = 100);
        
        // 内側のくり抜き
        translate([0, 0, bottom_thickness])
            cylinder(r = inner_radius, h = inner_height + 1, $fn = 100);
    }
}

module handle() {
    // 取手の位置（カップの外周から取手リングの中心までの距離）
    handle_offset = outer_radius + handle_ring_radius;
    
    // 縦向きのリング状取手（YZ平面上のトーラス）
    translate([handle_offset, 0, handle_center_height])
        rotate([0, 90, 0])
            rotate([90, 0, 0])
                rotate_extrude(angle = 360, $fn = 60)
                    translate([handle_ring_radius, 0, 0])
                        circle(r = handle_tube_radius, $fn = 30);
}

// マグカップ本体
cup_body();

// 取手
handle();