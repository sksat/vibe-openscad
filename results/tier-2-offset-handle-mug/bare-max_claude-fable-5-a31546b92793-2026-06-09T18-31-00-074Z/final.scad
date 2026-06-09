// ============================================
// マグカップ(取手は +X 軸方向の側面のみ)
// ============================================
$fn = 120;

/* ---- 本体パラメータ ---- */
mug_height   = 90;    // 全高
outer_dia    = 80;    // 外径
inner_dia    = 70;    // 内径(肉厚 5mm)
bottom_thick = 6;     // 底面の厚み

/* ---- 取手パラメータ ---- */
grip_w       = 25;    // 取手内側空間の幅(X方向)
grip_h       = 30;    // 取手内側空間の高さ(Z方向)
bar_thick    = 8;     // 取手の棒の太さ(断面)
handle_depth = 12;    // 取手の奥行き(Y方向)
embed        = 4;     // 本体壁への埋め込み量(肉厚5mm未満 → 内側へ貫通しない)

body_r   = outer_dia / 2;
handle_z = mug_height / 2;   // 高さ方向の中央に配置

/* ---- 本体:底付き中空円筒 ---- */
module mug_body() {
    difference() {
        cylinder(h = mug_height, d = outer_dia);
        // 内側をくり抜く(底 6mm を残し、上面は開口)
        translate([0, 0, bottom_thick])
            cylinder(h = mug_height - bottom_thick + 1, d = inner_dia);
    }
}

/* ---- D字形 取手断面(2D: x = 本体から外向き, y = 上下方向) ---- */
module handle_profile_2d() {
    r_in  = grip_h / 2;              // 内側半円の半径 (15)
    r_out = grip_h / 2 + bar_thick;  // 外側半円の半径 (23)
    difference() {
        // 外形:本体側(x負方向)は直線、外側(+x)は半円 → D字
        union() {
            translate([-embed, -r_out])
                square([embed + grip_w - r_in, 2 * r_out]);
            translate([grip_w - r_in, 0])
                circle(r = r_out);
        }
        // 内側の開口:高さ 30mm × 幅 25mm
        union() {
            translate([0, -r_in])
                square([grip_w - r_in, 2 * r_in]);
            translate([grip_w - r_in, 0])
                circle(r = r_in);
        }
    }
}

/* ---- 取手:+X 側面のみ、壁に embed 分食い込ませて確実に接続 ---- */
module handle() {
    translate([body_r, 0, handle_z])      // 外周面 (x = 40) に配置
        rotate([90, 0, 0])                // 断面を X-Z 平面に立てる
            linear_extrude(height = handle_depth, center = true)
                handle_profile_2d();
}

/* ---- 組み立て(本体と取手をオーバーラップさせて union → マニフォールド) ---- */
union() {
    mug_body();
    handle();
}