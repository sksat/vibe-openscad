// ===== パラメータ =====
$fn = 120;

outer_d   = 80;    // 外径
cup_h     = 100;   // 高さ
wall_t    = 4;     // 側面の肉厚
bottom_t  = 6;     // 底面の厚み

handle_r  = 12;    // 取手リングの半径(中心円の半径)
handle_t  = 5;     // 取手の太さ(管の半径)
handle_z  = cup_h / 2;            // 取手の高さ位置(中央)

// 取手中心を外周より外側に出し、指を通す開口部を
// カップ外周の外に確保する(開口部内縁が外壁より外側になる位置)
handle_x  = outer_d / 2 + 9;      // = 49mm: 開口部は半径42〜56mmの範囲で外に出る

// ===== マグカップ本体 + 取手 =====
difference() {
    union() {
        // 外側の円筒(カップ本体)
        cylinder(d = outer_d, h = cup_h);

        // リング状の取手(トーラス)
        translate([handle_x, 0, handle_z])
            rotate([90, 0, 0])          // リングを縦向き(XZ平面)に
                rotate_extrude(angle = 360)
                    translate([handle_r, 0, 0])
                        circle(r = handle_t);
    }

    // 内側のくり抜き(飲み物を入れる部分)
    translate([0, 0, bottom_t])
        cylinder(d = outer_d - 2 * wall_t, h = cup_h);
}