// マグカップのパラメータ
outer_diameter = 80;      // 外径
outer_radius = outer_diameter / 2;
height = 100;             // 高さ
wall_thickness = 4;      // 肉厚
bottom_thickness = 6;    // 底面の厚み
inner_radius = outer_radius - wall_thickness;
inner_height = height - bottom_thickness;

// 取手のパラメータ
handle_ring_radius = 12;       // 取手リングの半径(指を通す穴の太さ方向)
handle_tube_radius = 5;        // 取手の太さ(チューブの半径)
handle_height = height / 2;    // 取手を付ける高さ(中心高さ)

$fn = 100;

// カップ本体
module cup_body() {
    difference() {
        // 外側の円柱
        cylinder(h = height, r = outer_radius);
        // 内側のくり抜き
        translate([0, 0, bottom_thickness])
            cylinder(h = inner_height + 1, r = inner_radius);
    }
}

// 取手(リング状)
module handle() {
    translate([outer_radius - 2, 0, handle_height])
        rotate([90, 0, 0])
            rotate_extrude($fn = 100)
                translate([handle_ring_radius, 0, 0])
                    circle(r = handle_tube_radius);
}

// 全体の組み立て
union() {
    cup_body();
    handle();
}