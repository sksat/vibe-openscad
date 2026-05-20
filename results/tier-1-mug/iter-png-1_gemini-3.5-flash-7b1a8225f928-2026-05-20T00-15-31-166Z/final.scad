$fn = 100;

// マグカップの寸法
cup_height = 100;
cup_outer_radius = 40; // 外径 80mm のため、半径は 40mm
cup_wall_thickness = 4;
cup_bottom_thickness = 6;

// 取手（リング状）の寸法
handle_radius = 12;     // 取手のリング半径（中心からチューブ中心まで）
handle_thickness = 4;   // 取手の肉厚（チューブの半径）
handle_overlap = 2;     // カップ外壁との重なり（接合強度を保ちつつ、内側に突き出さないためのマージン）

// 取手を適切な位置（カップ外壁に少し食い込み、内壁には突き抜けない位置）に配置
handle_x = cup_outer_radius - handle_overlap + handle_radius + handle_thickness;

difference() {
    union() {
        // マグカップ本体（外側）
        cylinder(h=cup_height, r=cup_outer_radius);
        
        // 取手（中心の高さに配置）
        translate([handle_x, 0, cup_height / 2])
        rotate([90, 0, 0])
        rotate_extrude()
        translate([handle_radius, 0, 0])
        circle(r=handle_thickness);
    }
    
    // 内側のくり抜き（水漏れを防ぐため、取手と干渉しない範囲でくり抜く）
    translate([0, 0, cup_bottom_thickness])
        cylinder(h=cup_height - cup_bottom_thickness + 1, r=cup_outer_radius - cup_wall_thickness);
}