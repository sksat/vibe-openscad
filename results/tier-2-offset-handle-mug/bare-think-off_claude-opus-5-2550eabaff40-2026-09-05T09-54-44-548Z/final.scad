// ============================================
//  Mug with a D-shaped handle on the +X side
// ============================================

$fn = 96;

// ---- Body parameters ----
mug_outer_d   = 80;                  // 外径
mug_inner_d   = 70;                  // 内径 (肉厚 5mm)
mug_h         = 90;                  // 全体高さ
bottom_t      = 6;                   // 底の厚み

mug_outer_r   = mug_outer_d / 2;     // 40
mug_inner_r   = mug_inner_d / 2;     // 35

// ---- Handle parameters ----
hole_h        = 30;                  // 取手内側の空間 高さ
hole_w        = 25;                  // 取手内側の空間 幅 (X方向)
handle_t      = 10;                  // 取手の太さ (径方向/上下方向の枠幅)
handle_depth  = 14;                  // 取手の厚み (Y方向)
handle_zc     = mug_h / 2;           // 高さ方向中央
embed         = 4;                   // 本体へのめり込み量 (確実な union 用)

// 取手外形の全体サイズ
outer_h       = hole_h + 2 * handle_t;   // 50
outer_w       = hole_w + handle_t;       // 35 (本体側は本体に接続)

// ---- D shape (2D): 本体側が直線、外側が半円 ----
// x = 0 が直線側、+x 方向に膨らむ D 字
module d_profile(w, h) {
    r = h / 2;
    hull() {
        translate([0.001, -h/2]) square([0.001, h]);   // 直線側
        translate([w - r, 0]) circle(r = r);           // 外側の半円
    }
}

module handle() {
    // Y-Z 平面上に D 字を描き、Y 方向に押し出す
    translate([0, handle_depth/2, 0])
    rotate([90, 0, 0])
    linear_extrude(height = handle_depth, center = false)
    difference() {
        // 外形 D
        d_profile(outer_w, outer_h);
        // 内側の穴 D (高さ30 x 幅25)
        translate([0, 0])
        offset(r = 0)
        d_profile_hole();
    }
}

module d_profile_hole() {
    r = hole_h / 2;
    hull() {
        translate([-0.001, -hole_h/2]) square([0.001, hole_h]);
        translate([hole_w - r, 0]) circle(r = r);
    }
}

// ---- Assembly ----
module mug() {
    union() {
        // 本体
        difference() {
            cylinder(h = mug_h, r = mug_outer_r);
            translate([0, 0, bottom_t])
                cylinder(h = mug_h - bottom_t + 1, r = mug_inner_r);
        }

        // 取手 (+X 側のみ)。本体外周に embed 分めり込ませて確実に接続
        difference() {
            translate([mug_outer_r - embed, 0, handle_zc])
                handle();
            // 内壁側へはみ出さないよう、内側の空洞領域を削る
            translate([0, 0, bottom_t])
                cylinder(h = mug_h - bottom_t + 1, r = mug_inner_r);
        }
    }
}

mug();