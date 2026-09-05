// マグカップ
outer_d   = 80;    // 外径
height    = 100;   // 高さ
wall      = 4;     // 側面の肉厚
bottom    = 6;     // 底の厚み

handle_r   = 12;   // 取手リングの半径（内側の穴の半径）
handle_t   = 5;    // 取手の太さ（断面の半径）

$fn = 96;

// カップ本体
module cup_body() {
    difference() {
        cylinder(d = outer_d, h = height);
        translate([0, 0, bottom])
            cylinder(d = outer_d - 2 * wall, h = height);
    }
}

// リング状の取手
module handle() {
    // カップ外周から少し内側へ食い込ませて確実に接合させる
    translate([outer_d / 2 + handle_r - 1, 0, height / 2])
        rotate([90, 0, 0])
            rotate_extrude(convexity = 4)
                translate([handle_r + handle_t, 0, 0])
                    circle(r = handle_t);
}

union() {
    cup_body();
    difference() {
        handle();
        // カップ内部にはみ出した取手部分を削除
        translate([0, 0, bottom])
            cylinder(d = outer_d - 2 * wall, h = height);
    }
}