$fn = 100;

// マグカップの基本寸法
outer_diameter = 80;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;

// 取っ手の寸法
handle_major_radius = 12; // 取っ手自体の半径
handle_tube_radius = 6;   // 取っ手の肉厚（半径）

difference() {
    // 外形
    cylinder(h = height, d = outer_diameter);

    // 内側のくり抜き
    translate([0, 0, bottom_thickness])
        cylinder(h = height, d = outer_diameter - 2 * wall_thickness);
}

// 取っ手 (リング状)
translate([outer_diameter / 2, 0, height / 2]) // カップの側面に配置
rotate([0, 90, 0])                             // 垂直方向に回転
rotate_extrude()                               // 回転体を作成
translate([handle_major_radius, 0, 0])         // 取っ手の中心半径を設定
circle(r = handle_tube_radius);               // 取っ手の断面