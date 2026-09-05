$fn = 100;

// パラメータ
outer_diameter = 80;
outer_radius = outer_diameter / 2;  // 外半径: 40mm
cup_height = 100;                   // 高さ: 100mm
wall_thickness = 4;                 // 肉厚: 4mm
bottom_thickness = 6;               // 底面厚み: 6mm
inner_radius = outer_radius - wall_thickness; // 内半径: 36mm

handle_radius = 12;                 // 取手のリング半径: 12mm
handle_tube_radius = 3;             // 取手の断面半径: 3mm

difference() {
    union() {
        // カップ外側本体
        cylinder(r = outer_radius, h = cup_height);

        // リング状の取手 (中心高さ 50mm に配置し、カップ外周に接続)
        translate([outer_radius + handle_radius - handle_tube_radius, 0, cup_height / 2])
            rotate([90, 0, 0])
            rotate_extrude()
            translate([handle_radius, 0, 0])
            circle(r = handle_tube_radius);
    }

    // 内側のくり抜き (底厚6mmを残し、上部まで貫通)
    translate([0, 0, bottom_thickness])
        cylinder(r = inner_radius, h = cup_height - bottom_thickness + 1);
}