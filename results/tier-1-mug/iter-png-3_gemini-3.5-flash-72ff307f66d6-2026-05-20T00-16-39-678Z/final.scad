$fn = 100;

// マグカップの寸法
cup_height = 100;
cup_outer_radius = 40; // 外径 80mm のため、半径は 40mm
cup_wall_thickness = 4;
cup_bottom_thickness = 6;

// 取手（リング状）の寸法
// 「半径12mmの取手」に基づき、リングの中心半径（torus radius）を 12mm とします。
handle_radius = 12; 
handle_thickness = 3.5; // 指を通しやすく強度を保てる肉厚（断面半径）

// 取手をカップ外壁に適切に結合（内壁に突き出さず、しっかり固定される位置）
// カップ外壁は x = 40、内壁は x = 36。結合の食い込みを 2mm とするため、取手の最内端を x = 38 とします。
// 取手の最内端は handle_x - handle_radius - handle_thickness
handle_x = 38 + handle_radius + handle_thickness;

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
    
    // 内側のくり抜き
    translate([0, 0, cup_bottom_thickness])
        cylinder(h=cup_height - cup_bottom_thickness + 1, r=cup_outer_radius - cup_wall_thickness);
}