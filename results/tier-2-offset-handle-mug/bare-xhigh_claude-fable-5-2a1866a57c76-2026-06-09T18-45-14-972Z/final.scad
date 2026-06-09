// ===============================
// マグカップ(取手は +X 方向のみ)
// ===============================
$fn = 128;

// ---- 本体パラメータ ----
outer_d  = 80;   // 外径
inner_d  = 70;   // 内径(肉厚 5mm)
mug_h    = 90;   // 高さ
bottom_t = 6;    // 底面の厚み

// ---- 取手パラメータ ----
grip_h       = 30;  // 取手内側の空間 高さ
grip_w       = 25;  // 取手内側の空間 幅
handle_t     = 8;   // 取手の材料厚(リングの太さ)
handle_depth = 12;  // 取手の奥行き(Y 方向)
embed        = 4;   // 本体壁への食い込み量(マニフォールド確保)
handle_z     = mug_h / 2;  // 高さ方向中央に配置

R = outer_d / 2;  // 外半径 40

// ---- 本体(中空マグ) ----
module mug_body() {
    difference() {
        cylinder(h = mug_h, d = outer_d);
        // 内側をくり抜く(底は bottom_t 残す)
        translate([0, 0, bottom_t])
            cylinder(h = mug_h, d = inner_d);
    }
}

// ---- 2D D字形状 ----
// straight_x : 直線辺(本体側)の X 位置
// width      : 直線辺から外端までの幅
// half_h     : 高さの半分(半円の半径)
module d_shape(straight_x, width, half_h) {
    hull() {
        // 本体側の直線辺
        translate([straight_x, -half_h])
            square([0.01, 2 * half_h]);
        // 外側の半円
        translate([straight_x + width - half_h, 0])
            circle(r = half_h);
    }
}

// ---- 取手(D字リング、+X 方向) ----
module handle() {
    rotate([90, 0, 0])
        linear_extrude(height = handle_depth, center = true)
            difference() {
                // 外側 D(本体壁内 x = R - embed まで食い込ませる)
                d_shape(R - embed, grip_w + handle_t + embed, grip_h / 2 + handle_t);
                // 内側 D(指の入る空間: 幅 25 × 高さ 30)
                d_shape(R, grip_w, grip_h / 2);
            }
}

// ---- 組み立て ----
union() {
    mug_body();
    translate([0, 0, handle_z])
        handle();
}