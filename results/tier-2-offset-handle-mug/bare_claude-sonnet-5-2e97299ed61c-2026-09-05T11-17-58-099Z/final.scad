// ============================================
// 向き指定マグカップ (+X方向に取手)
// ============================================
$fn = 100;

// ---- 本体パラメータ ----
mug_or   = 40;   // 外径半径 (外径80mm)
mug_ir   = 35;   // 内径半径 (内径70mm, 肉厚5mm)
mug_h    = 90;   // 高さ
bottom_t = 6;    // 底面厚み

// ---- 取手パラメータ ----
handle_center_z   = mug_h / 2; // 取手の高さ方向中心 (45mm付近)
gap_h             = 30;  // 指入れ空間: 高さ
gap_w             = 25;  // 指入れ空間: 幅(本体表面からの奥行)
wall_t            = 10;  // 取手の肉厚(穴周囲)
embed             = 5;   // 本体壁への埋め込み量(壁厚5mm以内に収める)
handle_thickness  = 14;  // 取手の厚み(Y方向)

// D字形状(平坦な左辺 + 半円の右端)を作る2Dプロファイル
module d_profile(flat_x, width, height, center_z) {
    r = height / 2;
    x_mid = flat_x + width - r;
    difference() {
        union() {
            translate([flat_x, center_z - height/2])
                square([width, height]);
            translate([x_mid, center_z])
                circle(r = r);
        }
        // flat_x より左側を確実に切り落とし、平坦面を保証する
        translate([flat_x - 1000, center_z - 1000])
            square([1000, 2000]);
    }
}

// マグ本体(中空の円筒)
module mug_body() {
    difference() {
        cylinder(h = mug_h, r = mug_or);
        translate([0, 0, bottom_t])
            cylinder(h = mug_h - bottom_t + 1, r = mug_ir);
    }
}

// 取手(D字形、+X方向のみに配置)
module handle() {
    outer_flat_x = mug_or - embed;              // 本体壁内部まで埋め込む
    outer_width  = embed + gap_w + wall_t;      // 外側先端までの幅
    outer_height = gap_h + 2 * wall_t;          // 上下の肉厚を含む高さ

    hole_flat_x = mug_or;   // 穴は本体外周面から開始
    hole_width  = gap_w;
    hole_height = gap_h;

    translate([0, handle_thickness/2, 0])
    rotate([90, 0, 0])
    linear_extrude(height = handle_thickness)
        difference() {
            d_profile(outer_flat_x, outer_width, outer_height, handle_center_z);
            d_profile(hole_flat_x,  hole_width,  hole_height,  handle_center_z);
        }
}

// ---- 最終出力 ----
union() {
    mug_body();
    handle();
}