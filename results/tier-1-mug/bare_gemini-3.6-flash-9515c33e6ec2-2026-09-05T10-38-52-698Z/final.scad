$fn = 100;

// パラメータ設定
outer_diameter = 80;
outer_radius = outer_diameter / 2; // 40mm
height = 100;
wall_thickness = 4;
bottom_thickness = 6;
inner_radius = outer_radius - wall_thickness; // 36mm

// 取手のパラメータ
// 指を通せる穴の半径を12mmとし、取手の太さ(断面半径)を4mmに設定（主半径16mm）
handle_hole_radius = 12;
handle_thickness = 4;
handle_major_radius = handle_hole_radius + handle_thickness; // 16mm
handle_x_offset = outer_radius + 8; // カップ側面としっかり結合させる位置

difference() {
    // 形状の結合（カップ外形 + 取手）
    union() {
        // カップ本体
        cylinder(r = outer_radius, h = height);
        
        // リング状の取手
        translate([handle_x_offset, 0, height / 2])
        rotate([90, 0, 0])
        rotate_extrude()
        translate([handle_major_radius, 0, 0])
        circle(r = handle_thickness);
    }
    
    // 内側のくり抜き
    translate([0, 0, bottom_thickness])
    cylinder(r = inner_radius, h = height - bottom_thickness + 1);
}