// マグカップ パラメータ
outer_d = 80;      // 外径
height  = 100;     // 高さ
wall    = 4;       // 肉厚
bottom  = 6;       // 底厚

handle_r      = 12;  // 取手リングの穴半径(指を通す穴)
handle_thick  = 6;   // 取手の太さ(チューブの半径)
handle_z      = height / 2; // 取手の高さ位置

$fn = 100;

module mug_body() {
    difference() {
        // 外形
        cylinder(h = height, d = outer_d);
        // 内側くり抜き
        translate([0, 0, bottom])
            cylinder(h = height - bottom + 1, d = outer_d - 2 * wall);
    }
}

module handle() {
    // 取手:カップ外側に飛び出すリング(トーラス)
    // 取手の中心を、カップの外周から少し外側に置く
    handle_center_x = outer_d / 2 + handle_r * 0.3;
    
    translate([handle_center_x, 0, handle_z])
        rotate([90, 0, 0])
            rotate_extrude(convexity = 10)
                translate([handle_r, 0, 0])
                    circle(r = handle_thick);
}

module mug() {
    union() {
        mug_body();
        // 取手はカップ本体と交差する部分を残して結合
        intersection_union: 
        difference() {
            handle();
            // カップ内側の空洞には取手が入り込まないようにする
            translate([0, 0, bottom])
                cylinder(h = height - bottom + 1, d = outer_d - 2 * wall);
        }
    }
}

mug();