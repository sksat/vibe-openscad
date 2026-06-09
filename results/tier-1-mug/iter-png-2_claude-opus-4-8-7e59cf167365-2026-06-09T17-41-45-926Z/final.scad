// マグカップのパラメータ
outer_diameter = 80;      // 外径
outer_radius = outer_diameter / 2;
height = 100;             // 高さ
wall_thickness = 4;      // 肉厚
bottom_thickness = 6;    // 底面の厚み
inner_radius = outer_radius - wall_thickness;
inner_height = height - bottom_thickness;

// 取手のパラメータ
handle_tube_radius = 6;      // 取手の太さ(チューブの半径)
handle_ring_radius = 24;     // 取手リングの半径(指が通る大きさ)
handle_z = height / 2;       // 取手の取付け高さ(中心高さ)

$fn = 100;

// カップ本体
module cup_body() {
    difference() {
        // 外形
        cylinder(h = height, r = outer_radius);
        // 内側くり抜き
        translate([0, 0, bottom_thickness])
            cylinder(h = inner_height + 1, r = inner_radius);
    }
}

// 取手(リング状)
module handle() {
    // リングをカップ外周に少し食い込ませて確実に結合する
    translate([outer_radius - 4, 0, handle_z])
        rotate([90, 0, 0])
            rotate_extrude(angle = 360)
                translate([handle_ring_radius, 0, 0])
                    circle(r = handle_tube_radius);
}

// 全体の組み立て
union() {
    cup_body();
    handle();
}