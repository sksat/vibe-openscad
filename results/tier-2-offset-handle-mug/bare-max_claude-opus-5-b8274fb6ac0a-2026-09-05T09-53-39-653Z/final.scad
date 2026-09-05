// ============================================================
//  マグカップ(取手は +X 方向のみ)
//    本体: 外径80 / 内径70 / 高さ90 / 底厚6
//    取手: D字(外側が半円・本体側が直線)、内側空間 30(H) x 25(W)
// ============================================================
$fn = 120;

/* ---------------- 本体パラメータ ---------------- */
outer_d   = 80;                 // 外径
inner_d   = 70;                 // 内径(肉厚 5mm)
mug_h     = 90;                 // 全高
bottom_t  = 6;                  // 底面の厚み

outer_r   = outer_d / 2;        // 40
inner_r   = inner_d / 2;        // 35

/* ---------------- 取手パラメータ ---------------- */
grip_h    = 30;                 // 取手内側の空間:高さ
grip_w    = 25;                 // 取手内側の空間:幅(本体外周から外向き)
bar_t     = 10;                 // 取手の太さ(D字断面の肉厚)
handle_t  = 12;                 // 取手の厚み(Y方向)
embed     = 4;                  // 本体外周へのめり込み量(確実に union させる)
handle_z  = mug_h / 2;          // 取手の中心高さ(= 45mm : 高さ方向中央)

/* ---------------- 計算値 ---------------- */
out_flat_x = outer_r - embed;               // 36 : 外形D字の直線side(本体内部に食い込む)
out_tip_x  = outer_r + grip_w + bar_t;      // 75 : 外形D字の先端
out_w      = out_tip_x - out_flat_x;        // 39
out_h      = grip_h + 2 * bar_t;            // 50

in_flat_x  = out_flat_x - 1;                // 35 : 内穴は直線側を貫通させC字にする
in_tip_x   = outer_r + grip_w;              // 65
in_w       = in_tip_x - in_flat_x;          // 30
in_h       = grip_h;                        // 30

/* -------- D字 2Dプロファイル(左=直線 / 右=半円) -------- */
module d_profile(w, h) {
    hull() {
        translate([0, -h / 2]) square([0.01, h]);   // 直線側(本体側)
        translate([w - h / 2, 0]) circle(d = h);    // 半円側(外側)
    }
}

/* ---------------- 本体(中実) ---------------- */
module mug_body_solid() {
    cylinder(h = mug_h, r = outer_r);
}

/* ---------------- 内部の空洞 ---------------- */
module mug_cavity() {
    translate([0, 0, bottom_t])
        cylinder(h = mug_h - bottom_t + 1, r = inner_r);   // 上面は開口
}

/* ---------------- 取手(+X 側のみ) ---------------- */
module handle() {
    translate([0, 0, handle_z])
        rotate([90, 0, 0])
            linear_extrude(height = handle_t, center = true)
                difference() {
                    translate([out_flat_x, 0]) d_profile(out_w, out_h);
                    translate([in_flat_x, 0])  d_profile(in_w,  in_h);
                }
}

/* ---------------- 組み立て ---------------- */
module mug() {
    difference() {
        union() {
            mug_body_solid();
            handle();               // 本体外周に 4mm めり込ませて確実に結合
        }
        mug_cavity();               // 取手は内壁(r=35)に届かないので削られない
    }
}

mug();