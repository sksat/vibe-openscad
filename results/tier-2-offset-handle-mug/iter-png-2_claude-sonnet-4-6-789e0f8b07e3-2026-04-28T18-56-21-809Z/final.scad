$fn = 128;

outer_r = 40;
inner_r = 35;
mug_h   = 90;
bot_t   = 6;

handle_z    = mug_h / 2;   // 45mm: 高さ方向中央
h_space_h   = 30;          // 取手内側空間 高さ
h_space_w   = 25;          // 取手内側空間 幅
handle_t    = 8;           // 取手の肉厚(断面幅)

// 取手の概念:
//   - 外形: 半円(+X側) + 上下の直線部分(本体に接続)
//   - 内空: 高さ h_space_h x 幅 h_space_w
//   - 本体外壁(X=outer_r)から生える
//
// 構成:
//   1. 上バー: 本体壁からX方向に伸びる直方体
//   2. 下バー: 同上
//   3. 外側半円アーム: 上バーと下バーの外端を繋ぐ半円管
//      半円の中心: (outer_r + handle_t + h_space_w/2 + ... ) を計算
//
// 取手の外側半円:
//   上バー外端 X座標 = outer_r + handle_t + h_space_w
//   上バー Z = handle_z + h_space_h/2
//   下バー Z = handle_z - h_space_h/2
//   半円アームの中心Z = handle_z, 中心X = outer_r + handle_t + h_space_w
//   半円アームの半径 = h_space_h/2 = 15
//   アーム断面 = handle_t x handle_t の正方形断面を rotate_extrude

// 各部寸法
bar_x_start = outer_r - 3;               // 本体に3mm食い込んで確実に結合
bar_x_end   = outer_r + handle_t + h_space_w; // バーの外端X
bar_x_len   = bar_x_end - bar_x_start;
bar_z_top   = handle_z + h_space_h / 2;  // 45+15=60
bar_z_bot   = handle_z - h_space_h / 2;  // 45-15=30
arc_cx      = bar_x_end;                 // 半円中心X
arc_cz      = handle_z;                  // 半円中心Z
arc_r       = h_space_h / 2;             // =15 (半円の回転半径=内空高さ/2)

module handle_bar(z_center) {
    // Y方向に handle_t の幅を持つ直方体バー
    translate([bar_x_start, -handle_t/2, z_center - handle_t/2])
        cube([bar_x_len, handle_t, handle_t]);
}

module handle_arc() {
    // XZ平面内で、(arc_cx, arc_cz) を中心に半円を描く
    // 断面: handle_t x handle_t の正方形
    // +X側の半円(角度 -90° → +90°)
    N = 64;
    for (i = [0 : N-1]) {
        a1 = -90 + 180 * i       / N;
        a2 = -90 + 180 * (i+1)   / N;
        x1 = arc_cx + arc_r * cos(a1);
        z1 = arc_cz + arc_r * sin(a1);
        x2 = arc_cx + arc_r * cos(a2);
        z2 = arc_cz + arc_r * sin(a2);
        hull() {
            translate([x1, -handle_t/2, z1])
                cube([handle_t, handle_t, 0.01]);
            translate([x2, -handle_t/2, z2])
                cube([handle_t, handle_t, 0.01]);
        }
    }
}

module handle() {
    union() {
        handle_bar(bar_z_top);
        handle_bar(bar_z_bot);
        handle_arc();
    }
}

module mug_body() {
    difference() {
        cylinder(r = outer_r, h = mug_h);
        translate([0, 0, bot_t])
            cylinder(r = inner_r, h = mug_h - bot_t + 0.1);
    }
}

// Final model
union() {
    mug_body();
    handle();
}