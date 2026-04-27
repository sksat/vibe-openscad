// パラメータ設定
outer_diameter = 80;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;

handle_radius = 25; // 取手全体の半径
handle_tube_radius = 4; // 取手の棒の太さ（半径）
handle_offset = 35; // カップの中心から取手の中心までの距離

$fn = 100; // 解像度

union() {
    // カップ本体
    difference() {
        // 外側
        cylinder(d = outer_diameter, h = height);
        
        // 内側のくり抜き
        translate([0, 0, bottom_thickness])
            cylinder(d = outer_diameter - (wall_thickness * 2), h = height);
    }

    // 取手 (リング状)
    translate([outer_diameter / 2 + 10, 0, height / 2])
    rotate([0, 90, 0])
    rotate_extrude(angle = 360)
    translate([handle_radius - handle_tube_radius, 0, 0])
    circle(r = handle_tube_radius);
}