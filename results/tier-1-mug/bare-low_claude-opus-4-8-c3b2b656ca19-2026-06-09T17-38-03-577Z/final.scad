// マグカップ
$fn = 100;

outer_d = 80;      // 外径
height = 100;      // 高さ
wall = 4;          // 肉厚
bottom = 6;        // 底面の厚み

outer_r = outer_d / 2;
inner_r = outer_r - wall;

// 取手のパラメータ
handle_ring_r = 12;        // リング断面の半径(指を通す穴の半径)
handle_tube_r = 5;         // チューブ(取手本体)の太さ
handle_z = height / 2;     // 取手を付ける高さ(中心高さ)

module cup_body() {
    difference() {
        // 外形
        cylinder(h = height, r = outer_r);
        // 内側くり抜き
        translate([0, 0, bottom])
            cylinder(h = height - bottom + 1, r = inner_r);
    }
}

module handle() {
    // リング状の取手
    translate([outer_r + handle_ring_r - 2, 0, handle_z])
        rotate([90, 0, 0])
            rotate_extrude()
                translate([handle_ring_r, 0, 0])
                    circle(r = handle_tube_r);
}

union() {
    cup_body();
    handle();
}