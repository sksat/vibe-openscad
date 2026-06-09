// マグカップ パラメータ
outer_d = 80;      // 外径
height  = 100;     // 高さ
wall    = 4;       // 肉厚
bottom  = 6;       // 底面の厚み

outer_r = outer_d / 2;
inner_r = outer_r - wall;
inner_h = height - bottom;

// 取手パラメータ
handle_tube_r = 6;        // 取手の太さ(チューブ半径)
handle_ring_r = 12;       // 取手リングの半径(中心〜チューブ中心)
handle_z = height / 2;    // 取手の高さ位置

$fn = 100;

module cup_body() {
    difference() {
        // 外形
        cylinder(h = height, r = outer_r);
        // 内側のくり抜き
        translate([0, 0, bottom])
            cylinder(h = inner_h + 1, r = inner_r);
    }
}

module handle() {
    // カップ外周からはみ出す位置にリング状の取手を配置
    translate([outer_r + handle_ring_r - handle_tube_r, 0, handle_z])
        rotate([90, 0, 0])
            rotate_extrude(convexity = 10)
                translate([handle_ring_r, 0, 0])
                    circle(r = handle_tube_r);
}

union() {
    cup_body();
    handle();
}