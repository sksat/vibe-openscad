$fn = 100;

// マグカップのパラメータ
outer_radius = 80 / 2;     // 外半径 40mm (外径 80mm)
height = 100;              // 高さ 100mm
wall_thickness = 4;        // 肉厚 4mm
bottom_thickness = 6;      // 底面の厚み 6mm
inner_radius = outer_radius - wall_thickness; // 内半径 36mm

// 取手のパラメータ
handle_ring_radius = 20;   // 取手リングの中心半径
handle_tube_radius = 4;    // 取手の断面半径

union() {
    // カップ本体
    difference() {
        // 外形
        cylinder(r = outer_radius, h = height);
        
        // 内側のくり抜き
        translate([0, 0, bottom_thickness])
            cylinder(r = inner_radius, h = height - bottom_thickness + 1);
    }
    
    // 取手 (側面にリング状に配置)
    translate([outer_radius, 0, height / 2])
        rotate([90, 0, 0])
        rotate_extrude($fn = 60)
            translate([handle_ring_radius, 0, 0])
                circle(r = handle_tube_radius, $fn = 40);
}