// ============================================================
//  SHARP GP2Y0D413K0F  Distance Measuring Sensor Unit
//  外形モデル  (Outline Dimensions / Sheet No. E4-A00901EN)
//
//  座標系
//    単位   : mm
//    原点   : 本体(レンズケース 29.45 x 13.05 x 7.1)の中心
//    +X     : 本体幅方向 (受光素子側)
//    +Y     : 上 (ケース天面 / 刻印面側)
//    +Z     : レンズが向く方向 (被検出物側)
//    -Z     : 取付面 (PWB / コネクタ側)
// ============================================================

/* ---------------- 表示オプション ---------------- */
SHOW_CASE      = true;
SHOW_LENS      = true;
SHOW_PWB       = true;
SHOW_CONNECTOR = true;
SHOW_STAMP     = true;   // 天面の刻印 (SHARP / 0D413K F 44)

$fn = $preview ? 48 : 120;

/* ---------------- 主要寸法 ---------------- */
BODY_W    = 29.45;              // 本体幅
CASE_H    = 13.05;              // レンズケース高さ
CASE_D    =  7.10;              // レンズケース奥行 (前面凸部含む) 7.1±0.1
BOSS_D    =  2.00;              // 前面凸部(レンズ部)の突出量
BOSS_H    =  7.20;              // 前面凸部の高さ
BOSS_TOP  =  8.40;              // ケース下端 → 前面凸部上端
BOSS_W    = BODY_W - 1.40;      // 前面凸部の幅(周囲に段差)

TOTAL_H   = 18.90;              // 全高 (ケース天面 → PWB 下端) 18.9±0.3
PWB_T     =  1.20;              // PWB (紙フェノール) 厚
PWB_W     = BODY_W;             // PWB 幅

EMIT_OFS  =  4.50;              // 左端 → 発光レンズ中心  (*4.5)
DET_OFS   = 19.70;              // 左端 → 受光レンズ中心  (*19.7)

/* --- 光学窓 / レンズ --- */
WIN_H     =  5.60;              // 窓(凹み)の高さ
WIN_D     =  0.80;              // 窓の掘り込み深さ
EMIT_WIN_W=  7.00;              // 発光側 窓幅
DET_WIN_W =  9.40;              // 受光側 窓幅
LENS_D_E  =  5.20;              // 発光レンズ径
LENS_D_D  =  5.00;              // 受光レンズ径
LENS_SINK =  0.20;              // レンズ面の沈み量

/* --- ケース内側 (背面の肉抜き) --- */
WALL      =  1.20;
HOLLOW_D  =  3.00;

/* --- コネクタ : JCTC 12001W90-3P-HF (1.0mm ピッチ 3P ライトアングル) --- */
CONN_W    =  6.40;
CONN_H    =  4.40;
CONN_D    =  3.30;              // PWB 前面からの突出 (3.3)
CONN_CX   = -0.50;              // 本体中心からの X オフセット
CONN_WALL =  0.70;
CONN_BASE =  0.90;
CONN_PITCH=  1.00;
PIN_S     =  0.40;

/* ---------------- 派生値 ---------------- */
case_zb  = -CASE_D/2;               // ケース後面 (= PWB 取付面)   -3.550
case_zf  =  CASE_D/2;               // 前面凸部の前面              +3.550
body_zf  =  case_zf - BOSS_D;       // 本体ブロック前面            +1.550
case_yb  = -CASE_H/2;               // ケース下端                  -6.525
case_yt  =  CASE_H/2;               // ケース上端 (天面)           +6.525
boss_yt  =  case_yb + BOSS_TOP;     // 凸部上端                    +1.875
boss_yb  =  boss_yt - BOSS_H;       // 凸部下端                    -5.325
lens_y   = (boss_yt + boss_yb)/2;   // 光軸高さ                    -1.725
emit_x   = -BODY_W/2 + EMIT_OFS;    // 発光レンズ中心 X           -10.225
det_x    = -BODY_W/2 + DET_OFS;     // 受光レンズ中心 X            +4.975

pwb_yt   =  case_yt;                // PWB 上端 (ケース天面と面一)
pwb_yb   =  case_yt - TOTAL_H;      // PWB 下端                   -12.375
pwb_zf   =  case_zb;                // PWB 前面
pwb_zb   =  case_zb - PWB_T;        // PWB 後面 (取付面)           -4.750

conn_yt  =  case_yb;                // コネクタ上端 = ケース下端
conn_yb  =  conn_yt - CONN_H;
conn_yc  = (conn_yt + conn_yb)/2;

/* ============================================================
   モジュール
   ============================================================ */

// --- 光学窓 (凹み) の切り欠き ---
module window_cut(cx, w) {
    translate([cx - w/2, lens_y - WIN_H/2, case_zf - WIN_D])
        cube([w, WIN_H, WIN_D + 0.5]);
}

// --- 天面の刻印 (彫り込み) ---
module stamp_cut() {
    translate([0, case_yt + 0.01, 0])
        rotate([90, 0, 0])
            linear_extrude(height = 0.30)
                union() {
                    translate([0, -1.6])
                        text("SHARP", size = 2.6, halign = "center",
                             valign = "center", spacing = 1.1);
                    translate([0,  1.9])
                        text("0D413K F 44", size = 1.7, halign = "center",
                             valign = "center");
                }
}

// --- レンズケース (Carbonic ABS / 導電性樹脂) ---
module lens_case() {
    color("#232323")
    difference() {
        union() {
            // 本体ブロック 29.45 x 13.05 x (7.1-2.0)
            translate([-BODY_W/2, case_yb, case_zb])
                cube([BODY_W, CASE_H, CASE_D - BOSS_D]);
            // 前面凸部 (レンズ部) 突出 2.0 / 高さ 7.2
            translate([-BOSS_W/2, boss_yb, body_zf])
                cube([BOSS_W, BOSS_H, BOSS_D]);
        }
        // 発光側 / 受光側 の窓
        window_cut(emit_x, EMIT_WIN_W);
        window_cut(det_x,  DET_WIN_W);

        // 背面の肉抜き
        translate([-BODY_W/2 + WALL, case_yb + WALL, case_zb - 0.1])
            cube([BODY_W - 2*WALL, CASE_H - 2*WALL, HOLLOW_D + 0.1]);

        // 刻印
        if (SHOW_STAMP) stamp_cut();
    }
}

// --- レンズ 1 個分 (アクリル酸樹脂 / 可視光カット) ---
module lens_one(cx, d) {
    h = WIN_D - LENS_SINK;
    translate([cx, lens_y, case_zf - WIN_D]) {
        cylinder(h = h - 0.25, d = d);
        translate([0, 0, h - 0.25])
            cylinder(h = 0.25, d1 = d, d2 = d - 0.6);
    }
}

module lenses() {
    color("#3d0a0a", 0.95) {
        lens_one(emit_x, LENS_D_E);   // Light emitter
        lens_one(det_x,  LENS_D_D);   // Light detector
    }
}

// --- PWB (紙フェノール) ---
module pwb() {
    color("#c2a464")
    translate([-PWB_W/2, pwb_yb, pwb_zb])
        cube([PWB_W, TOTAL_H, PWB_T]);
}

// --- コネクタ JCTC 12001W90-3P-HF ---
module connector() {
    // ハウジング
    color("#efece0")
    difference() {
        translate([CONN_CX - CONN_W/2, conn_yb, pwb_zf])
            cube([CONN_W, CONN_H, CONN_D]);
        translate([CONN_CX - (CONN_W - 2*CONN_WALL)/2,
                   conn_yb + CONN_WALL,
                   pwb_zf + CONN_BASE])
            cube([CONN_W - 2*CONN_WALL, CONN_H - 2*CONN_WALL, CONN_D]);
    }
    // 端子 1:Vo  2:GND  3:Vcc
    color("#c9a227")
    for (i = [-1, 0, 1]) {
        // 前方(嵌合側)ピン
        translate([CONN_CX + i*CONN_PITCH - PIN_S/2, conn_yc - PIN_S/2,
                   pwb_zf + CONN_BASE])
            cube([PIN_S, PIN_S, CONN_D - CONN_BASE - 0.5]);
        // 基板貫通側のはんだ足
        translate([CONN_CX + i*CONN_PITCH - PIN_S/2, conn_yc - PIN_S/2,
                   pwb_zb - 0.80])
            cube([PIN_S, PIN_S, PWB_T + 0.80]);
    }
}

/* ============================================================
   アセンブリ
   ============================================================ */
module gp2y0d413k0f() {
    if (SHOW_CASE)      lens_case();
    if (SHOW_LENS)      lenses();
    if (SHOW_PWB)       pwb();
    if (SHOW_CONNECTOR) connector();
}

gp2y0d413k0f();