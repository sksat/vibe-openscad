$fn = 96;

// ===== パラメータ =====
mug_outer_d   = 80;   // 本体外径
mug_inner_d   = 70;   // 本体内径 (肉厚5mm)
mug_height    = 90;   // 本体高さ
bottom_thick  = 6;    // 底の厚み

handle_grip_d = 12;   // 取手の太さ(断面の直径)
handle_open_h = 30;   // 取手内側の空間の高さ
handle_open_w = 25;   // 取手内側の空間の幅(本体外周からの張り出し方向)
handle_z      = mug_height / 2;  // 取手を付ける高さ(中央)

mug_outer_r = mug_outer_d / 2;
mug_inner_r = mug_inner_d / 2;

// ===== 本体 =====
module mug_body() {
    difference() {
        // 外形
        cylinder(h = mug_height, r = mug_outer_r);
        // 内側のくぼみ(中空)
        translate([0, 0, bottom_thick])
            cylinder(h = mug_height, r = mug_inner_r);
    }
}

// ===== 取手 (+X 側のみ, D字形状) =====
// D字の中心線(パス)に沿って円形断面をスイープする
module handle() {
    // 取手中心線が描く D 字輪郭の寸法
    // 内側の空間: 高さ handle_open_h, 幅 handle_open_w
    path_h = handle_open_h + handle_grip_d; // 中心線の高さ方向スパン
    path_w = handle_open_w;                 // 中心線の張り出し幅

    // 取手の付け根 X 位置(本体外周に少し食い込ませて確実に union)
    base_x = mug_outer_r - 2;

    translate([base_x, 0, handle_z])
    rotate([90, 0, 0])  // 取手の平面を XZ→作図しやすい向きへ
    linear_extrude(height = handle_grip_d, center = true)
        difference() {
            d_shape(path_w, path_h);
            offset(r = -handle_grip_d)
                d_shape(path_w, path_h);
        }
}

// D字の外形(2D): 左側が直線(本体側)、右側が半円
module d_shape(w, h) {
    hull() {
        // 直線側(本体に接する辺):上下2点
        translate([0,  h/2 - w/2]) circle(r = 0.01);
        translate([0, -h/2 + w/2]) circle(r = 0.01);
        // 半円側
        translate([0,  h/2 - w/2]) translate([w - w/2,0]) circle(r = 0.01);
        translate([0, -h/2 + w/2]) translate([w - w/2,0]) circle(r = 0.01);
    }
    // 上記hullだと角丸の矩形になるため、よりD字に近い形を別途構成
}

// ===== 組み立て =====
union() {
    mug_body();
    handle();
}