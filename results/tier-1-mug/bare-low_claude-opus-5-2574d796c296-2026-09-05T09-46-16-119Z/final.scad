// ===== マグカップ =====
// 外径 80mm / 高さ 100mm / 肉厚 4mm / 底厚 6mm
// 取手: リング状 (中心半径 12mm) を側面中央高さに配置

$fn = 120;

outer_d    = 80;      // 外径
outer_r    = outer_d / 2;
height     = 100;     // 全高
wall       = 4;       // 側面肉厚
bottom     = 6;       // 底厚

handle_r     = 12;    // 取手リングの中心半径(穴を含む輪の半径)
handle_thick = 6;     // 取手の太さ(断面直径)
handle_z     = height / 2;   // 取手の取り付け高さ(中心高さ)
// 外周からのはみ出しを確保するため、リング中心を外周付近に置く
handle_x     = outer_r - 2;

module cup_body() {
    difference() {
        // 外形
        cylinder(h = height, r = outer_r);
        // 内側くり抜き
        translate([0, 0, bottom])
            cylinder(h = height - bottom + 1, r = outer_r - wall);
    }
}

module handle() {
    // リング状の取手(トーラス)
    translate([handle_x, 0, handle_z])
        rotate([90, 0, 0])
            rotate_extrude(convexity = 10)
                translate([handle_r, 0, 0])
                    circle(d = handle_thick);
}

module mug() {
    difference() {
        union() {
            cup_body();
            // 取手のうちカップ外側にある部分のみ使用
            difference() {
                handle();
                cylinder(h = height, r = outer_r - 0.01);
            }
            // 取手をカップ壁面に接合する部分
            intersection() {
                handle();
                cylinder(h = height, r = outer_r);
            }
        }
        // 内側の空間は必ず空けておく
        translate([0, 0, bottom])
            cylinder(h = height - bottom + 1, r = outer_r - wall);
    }
}

mug();