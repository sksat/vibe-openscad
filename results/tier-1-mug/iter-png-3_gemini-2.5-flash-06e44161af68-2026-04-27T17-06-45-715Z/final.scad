// 定数定義
D_outer = 80;    // 外径
H_cup = 100;     // 高さ
thickness_wall = 4; // 肉厚
thickness_bottom = 6; // 底面の厚み

// 「外径方向に飛び出す半径 12mm の取手」について
// 前回のコードでは「取手全体がカップの外径から12mm飛び出す」と解釈し、取手のチューブの半径を6mmとしましたが、
// 「半径 12mm の取手」という記述をより直接的に解釈し、今回は**取手のチューブ自体の半径を12mm**とします。
// （これにより、取手はかなり太くなりますが、指示に忠実に従います。）
R_handle_tube = 12; // 取手のチューブの半径

// 指が通る穴の直径
// 問題文に明示がないため、指が通りやすい適切なサイズとして40mmを維持します。
D_finger_hole = 40;

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
            // Z-fightingを避けるため、内側の円筒の高さをわずかに外側より高くする
            cylinder(h = H_cup - thickness_bottom + 0.1, r = R_inner, center = false, $fn = 60);
        }
    }
}

// 取手
module handle() {
    // torusのrは、チューブ中心が描く円の半径
    // これは指が通る穴の半径とチューブの半径の和
    handle_torus_r1 = R_finger_hole + R_handle_tube;

    // 取手の中心X座標
    // 取手の最も内側の面がカップの外周 (R_outer) に接するように配置します。
    // torusは回転後、その最も内側のX座標が (handle_pos_x - (handle_torus_r1 + R_handle_tube)) となるので、
    // これが R_outer と等しくなるように handle_pos_x を計算します。
    handle_pos_x = R_outer + handle_torus_r1 + R_handle_tube;

    // 取手の中心Z座標 (カップの高さの中心)
    handle_pos_z = H_cup / 2;

    // torusはデフォルトでXY平面にリングの中心が来てZ軸に穴が開く。
    // これをY軸周りに90度回転させることで、穴がX軸を向き、リングがXZ平面に広がる形にする。
    // その後、所定の位置に平行移動する。
    translate([handle_pos_x, 0, handle_pos_z]) {
        rotate([0, 90, 0]) { // Y軸周りに90度回転
            torus(r = handle_torus_r1, r2 = R_handle_tube, $fn = 60);
        }
    }
}

// 全体を結合
union() {
    mug_body();
    handle();
}