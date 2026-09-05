// ============================================================
//  SHARP GP2Y0D413K0F  Distance Measuring Sensor Unit
//  外形モデル (データシート 2 ページ目 "Outline Dimensions" より)
//    単位 : mm
//    原点 : 本体ケースの中心
//    +Y   : レンズ側(前面) / +Z : 上 (コネクタは下面)
//  Note1 "*" 印はレンズ中心位置寸法
//  Note2 一般公差 ±0.3
//  Note3 ( ) 内は参考寸法
// ============================================================

$fn = 72;

/* ---------------- 主要寸法 ---------------- */
case_w     = 29.45;   // ケース幅
case_h     = 13.05;   // ケース高さ (13.05)
case_d     =  6.30;   // (6.3)  ケース本体の奥行き
lc_d       =  7.10;   // 7.1±0.1 レンズケース(前面突出部)の奥行き
total_d    = case_d + lc_d;   // 13.4 ≒ 13.5 (全奥行き)
total_h    = 18.90;   // 18.9 +0.3/-0.3 (ケース上面～コネクタ下端)

lc_h       =  8.40;   // 8.4  レンズケース高さ
lc_bot     =  3.75;   // 3.75 ケース底面～レンズケース下端
lc_w       = 25.00;   // (参考) レンズケース幅
lc_x0      =  0.90;   // (参考) ケース左端～レンズケース左端

emit_x     =  4.50;   // *4.5   発光部レンズ中心 (ケース左端から)
det_x      = 19.70;   // *19.7  受光部レンズ中心 (ケース左端から)
lens_zb    =  7.20;   // 7.2  ケース底面(=PWB上面)～レンズ中心
                      //      (側面図の 8.4 は PWB 下面基準 : 8.4-7.2=1.2=PWB厚)

emit_dia   =  5.40;   // (参考) 発光部レンズ(円窓)径
det_w      = 11.60;   // (参考) 受光部レンズ(矩形窓)幅
det_h      =  6.40;   // (参考) 受光部レンズ(矩形窓)高さ
win_depth  =  1.00;   // (参考) 窓の彫り込み深さ
lens_set   =  0.30;   // (参考) レンズ面の引き込み量

pwb_t      =  1.20;   // 1.2  PWB(Paper phenol) 厚
pwb_w      = 27.95;   // 7.5 + 4.15 + 16.3
pwb_d      =  9.00;   // (参考) PWB 奥行き

// コネクタ : Shenglan Technology (JCTC) 12001W90-3P-HF (1.25mm ピッチ 3極 L型)
conn_w     =  5.60;   // (参考) ハウジング幅
conn_d     =  4.60;   // (参考) ハウジング奥行き
conn_pitch =  1.25;   // (参考) ピン間ピッチ
pin_sq     =  0.40;   // (参考) ピン角寸法
notch_w    = 10.10;   // 10.1 コネクタ部のケース逃げ幅

/* ---------------- 派生値 ---------------- */
x_l   = -case_w/2;            // ケース左端
y_b   = -total_d/2;           // 最背面
y_f   =  total_d/2;           // レンズケース前面
z_b   = -case_h/2;            // ケース底面
z_t   =  case_h/2;            // ケース上面

emit_cx = x_l + emit_x;
det_cx  = x_l + det_x;
lc_cx   = x_l + lc_x0 + lc_w/2;
lens_cz = z_b + lens_zb;

pwb_z1  = z_b;                // PWB 上面 (ケース底面)
pwb_z0  = z_b - pwb_t;        // PWB 下面
conn_h  = pwb_z0 - (z_t - total_h);   // = 4.65 (全高 18.9 に合わせる)
conn_y  = y_b + pwb_d/2;

/* ---------------- 窓の切り欠き ---------------- */
module emitter_cut(cl = 0){
    translate([emit_cx, y_f - win_depth, lens_cz])
        rotate([-90, 0, 0])
            cylinder(d = emit_dia + cl, h = win_depth + 0.2);
}

module detector_cut(cl = 0){
    translate([det_cx, y_f - win_depth/2 + 0.1, lens_cz])
        cube([det_w + cl, win_depth + 0.2, det_h + cl], center = true);
}

/* ---------------- ケース (Carbonic ABS) ---------------- */
module case_shell(){
    difference(){
        union(){
            // 本体ケース(概形は直方体)
            translate([0, y_b + case_d/2, 0])
                cube([case_w, case_d, case_h], center = true);
            // レンズケース(前面に飛び出す突起)
            translate([lc_cx, y_b + case_d + lc_d/2, z_b + lc_bot + lc_h/2])
                cube([lc_w, lc_d, lc_h], center = true);
        }
        // 2 つの窓
        emitter_cut(0.20);
        detector_cut(0.20);
        // コネクタ部の逃げ (10.1)
        translate([0, conn_y, z_b])
            cube([notch_w, pwb_d + 0.2, 1.6], center = true);
    }
}

/* ---------------- レンズ (Acrylic acid resin) ---------------- */
module lens_emitter(){          // 発光部 : 円形窓 (左側)
    translate([emit_cx, y_f - win_depth, lens_cz])
        rotate([-90, 0, 0])
            cylinder(d = emit_dia, h = win_depth - lens_set);
}

module lens_detector(){         // 受光部 : 矩形窓 (右側)
    translate([det_cx,
               y_f - win_depth + (win_depth - lens_set)/2,
               lens_cz])
        cube([det_w, win_depth - lens_set, det_h], center = true);
}

/* ---------------- PWB (Paper phenol) ---------------- */
module pwb(){
    translate([0, y_b + pwb_d/2, pwb_z0 + pwb_t/2])
        cube([pwb_w, pwb_d, pwb_t], center = true);
}

/* ---------------- コネクタ (JCTC 12001W90-3P-HF) ---------------- */
module connector(){
    // ハウジング (下向き開口の簡易表現)
    color("Ivory")
    difference(){
        translate([0, conn_y, pwb_z0 - conn_h/2])
            cube([conn_w, conn_d, conn_h], center = true);
        translate([0, conn_y, pwb_z0 - conn_h/2 - 0.5])
            cube([conn_w - 1.0, conn_d - 1.0, conn_h - 0.8], center = true);
    }
    // 端子 (1)Vo (2)GND (3)Vcc
    color("Goldenrod")
    for(i = [-1, 0, 1])
        translate([i * conn_pitch, conn_y, pwb_z0 - conn_h + 1.2])
            cube([pin_sq, pin_sq, conn_h * 0.75], center = false);
}

/* ---------------- 組み立て ---------------- */
module gp2y0d413k0f(){
    color("DimGray")   case_shell();     // Case : Carbonic ABS
    color([0.10, 0.10, 0.12]) lens_emitter();
    color([0.10, 0.10, 0.12]) lens_detector();
    color("DarkGreen") pwb();            // PWB  : Paper phenol
    connector();
}

gp2y0d413k0f();