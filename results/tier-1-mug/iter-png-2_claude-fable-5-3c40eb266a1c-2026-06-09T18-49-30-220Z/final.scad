// マグカップ
$fn = 100;

// パラメータ
outer_d       = 80;   // 外径
cup_h         = 100;  // 高さ
wall_t        = 4;    // 側面の肉厚
bottom_t      = 6;    // 底面の厚み
handle_r      = 12;   // 取手リングの半径(中心円の半径)
handle_tube_r = 4;    // 取手の太さ(断面半径)

// 取手(トーラス)
module handle() {
    // カップ外壁にしっかり食い込ませて接合し、
    // 外側へ大きく張り出して指が通る穴を確保する
    translate([outer_d/2 + handle_r - 2, 0, cup_h/2])
        rotate([90, 0, 0])
            rotate_extrude(angle = 360)
                translate([handle_r, 0, 0])
                    circle(r = handle_tube_r);
}

// マグカップ本体
difference() {
    union() {
        // カップ外形
        cylinder(h = cup_h, d = outer_d);
        // 取手
        handle();
    }
    // 内側をくり抜く(底面厚 6mm を残す)
    // 取手がカップ内部にはみ出した部分もここで除去される
    translate([0, 0, bottom_t])
        cylinder(h = cup_h, d = outer_d - 2 * wall_t);
}