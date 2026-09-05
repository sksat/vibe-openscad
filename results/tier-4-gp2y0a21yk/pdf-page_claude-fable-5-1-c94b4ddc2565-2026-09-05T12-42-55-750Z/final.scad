// Sharp GP2Y0A21YK0F 測距センサ 外形モデル (単位: mm)
// 原点 = 本体中心, +Z = 上(レンズ面), +Y = 前

$fn = 64;

// ---- 寸法 (データシート 外形寸法図より) ----
body_w   = 29.5;   // 本体幅 (X)
body_d   = 7.2;    // 本体奥行 (Y)
body_h   = 13;     // 本体高さ (Z)
lens_d   = 6.3;    // レンズケース突起 奥行
lens_h   = 2;      // レンズケース突起 高さ
emit_w   = 7.5;    // 発光側レンズ窓 幅
gap_w    = 4.15;   // 発光/受光 窓間隔
det_w    = 16.3;   // 受光側レンズ窓 幅
emit_cx  = -body_w/2 + 4.5;      // * 発光レンズ中心
det_cx   = emit_cx + 20;         // * 受光レンズ中心 (20±0.1)
lens_dia = 5.5;                  // レンズ円窓 直径
hole_pitch = 37;                 // 取付穴ピッチ
ear_r    = 3.75;                 // 取付耳 R
hole_dia = 3.2;                  // 取付穴 φ3.2
bar_t    = 2;                    // 連結バー厚 (2〜1.5)
total_h  = 13.5;                 // 全高 (バー含む)
conn_w   = 10.1;                 // コネクタ幅
pwb_t    = 1.2;                  // PWB 厚
conn_h   = 3.3;                  // コネクタ高さ (参考)
total_hc = 18.9;                 // コネクタ含む全高 (参考)

z_bot = -body_h/2;               // 本体底面
z_top =  body_h/2;               // 本体上面

module lens_case() {
    // 本体ケース
    translate([-body_w/2, -body_d/2, z_bot])
        cube([body_w, body_d, body_h]);

    // レンズ突起 (発光側)
    x0 = emit_cx - emit_w/2;
    translate([x0, -lens_d/2, z_top])
        cube([emit_w, lens_d, lens_h]);

    // レンズ突起 (受光側)
    x1 = x0 + emit_w + gap_w;
    translate([x1, -lens_d/2, z_top])
        cube([det_w, lens_d, lens_h]);
}

module lenses() {
    // 発光側 円形レンズ (窓から僅かに突出)
    translate([emit_cx, 0, z_top + lens_h - 0.5])
        cylinder(d = lens_dia, h = 1.0);

    // 受光側 矩形窓 + 円形レンズ
    x0 = emit_cx - emit_w/2 + emit_w + gap_w;
    translate([x0 + 0.8, -lens_d/2 + 0.8, z_top + lens_h - 0.3])
        cube([det_w - 1.6, lens_d - 1.6, 0.4]);
    translate([det_cx, 0, z_top + lens_h - 0.3])
        cylinder(d = lens_dia, h = 0.8);
}

module mounting_bar() {
    z0 = z_bot - (total_h - body_h);   // バー底面 (全高13.5)
    difference() {
        hull() {
            for (sx = [-1, 1])
                translate([sx * hole_pitch/2, 0, z0])
                    cylinder(r = ear_r, h = bar_t);
            translate([-body_w/2, -body_d/2, z0])
                cube([body_w, body_d, bar_t]);
        }
        // 取付穴 φ3.2 ×2
        for (sx = [-1, 1])
            translate([sx * hole_pitch/2, 0, z0 - 1])
                cylinder(d = hole_dia, h = bar_t + 2);
        // ケーブル/コネクタ取り出し切欠き
        translate([-conn_w/2, -body_d/2 - 1, z0 - 1])
            cube([conn_w, body_d/2 + 1.5, bar_t + 2]);
    }
}

module pwb_and_cable() {
    z0 = z_bot - (total_h - body_h);
    // PWB (紙フェノール) 簡易表現
    translate([-conn_w/2, -body_d/2, z0 - pwb_t])
        cube([conn_w, body_d * 0.8, pwb_t]);
    // コネクタ (本体側 3P)
    translate([-conn_w/2, -body_d/2 + 0.5, z0 - pwb_t - conn_h])
        cube([conn_w, 4.5, conn_h]);
    // ケーブル (JST PHR-3 へ) 丸棒で簡易表現
    for (i = [-1, 0, 1])
        translate([i * 2.0, -body_d/2 + 2.75, z0 - pwb_t - conn_h])
            rotate([180, 0, 0])
                cylinder(d = 1.2, h = 15);
}

module GP2Y0A21YK0F() {
    color("DimGray") lens_case();
    color([0.15, 0.1, 0.1]) lenses();
    color("DimGray") mounting_bar();
    color("Tan")     pwb_and_cable();
}

GP2Y0A21YK0F();