// 定数定義
D_outer = 80;    // 外径
H_cup = 100;     // 高さ
thickness_wall = 4; // 肉厚
thickness_bottom = 6; // 底面の厚み

R_handle_tube = 12; // 取手のチューブの半径 (取手自体の半径)
D_finger_hole = 40; // 指が通る穴の直径 (適当な値、調整可能)

// 半径計算
R_outer = D_outer / 2;
R_inner = R_outer - thickness_wall;
R_finger_hole = D_finger_hole / 2;

// マグカップ本体
module mug_body() {
    difference() {
        // 外側の円筒
        cylinder(h = H_cup, r = R_outer, center = false, $fn = 60);

        // 内側をくり抜く円筒
        translate([0, 0, thickness_bottom]) {
            cylinder(h = H_cup - thickness_bottom, r = R_inner, center = false, $fn = 60);
        }
    }
}

// 取手
module handle() {
    // torusのr1は、チューブ中心が描く円の半径
    // torusのr2は、チューブ自体の半径 (R_handle_tube)
    // r1 = 指が通る穴の半径 + チューブの半径
    handle_torus_r1 = R_finger_hole + R_handle_tube;

    // 取手の中心X座標
    // カップの中心から: カップの外側半径 + 指が通る穴の半径 + チューブの半径
    handle_pos_x = R_outer + R_finger_hole + R_handle_tube;

    // 取手の中心Z座標 (カップの高さの中心)
    handle_pos_z = H_cup / 2;

    // torusはデフォルトでXY平面にリングの中心が来てZ軸に穴が開く。
    // これをY軸周りに90度回転させることで、穴がY軸を向き、リングがX軸方向に飛び出す形にする。
    // その後、所定の位置に平行移動する。
    translate([handle_pos_x, 0, handle_pos_z]) {
        rotate([0, 90, 0]) {
            torus(r = handle_torus_r1, r2 = R_handle_tube, $fn = 60);
        }
    }
}

// 全体を結合
union() {
    mug_body();
    handle();
}