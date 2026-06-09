// ============================================================
// Sharp GP2Y0A21YK0F  IR 測距センサ (10-80cm, アナログ出力)
// データシート p.2 "Outline Dimensions" による外形モデル
// 単位: mm / 原点: 本体ケース中心 / +Z: 上(レンズ側) / +Y: 前方
// ============================================================
$fn = 64;

// ---------------- データシート寸法 ----------------
body_l       = 29.5;            // 本体ケース長さ (X)
body_w       = 13.0;            // 本体ケース奥行 (Y)
total_h      = 13.5;            // レンズ突起込み全高 (Z)
turret_h     = 2.7;             // レンズ突起の飛び出し量
case_h       = total_h - turret_h;

hole_pitch   = 37.0;            // 取付穴ピッチ
hole_d       = 3.2;             // φ3.2 hole
tab_r        = 3.75;            // R3.75 取付タブ
tab_t        = 3.0;             // タブ厚 (Y方向, 近似)

em_turret_w  = 7.5;             // 発光側レンズ突起の幅
turret_gap   = 4.15;            // 突起間ギャップ
det_turret_w = 16.3;            // 受光側レンズ突起の幅
turret_d     = 6.3;             // 突起の奥行 (Y)
turret_setb  = 2.0;             // 前面からのセットバック

em_cx  = -body_l/2 + 4.5;       // * 発光レンズ中心 (左端から4.5)
det_cx = em_cx + 20.0;          // * レンズ中心間 20±0.1

bar_w     = 14.75;              // 連結バー幅
bar_x0    = -body_l/2 + 3.75;   // バー左端 (ケース左端から3.75)
overall_h = 18.9;               // ( ) バー込み参考全高
bar_h     = overall_h - total_h;// = 5.4
bar_d     = 6.0;                // バー奥行 (近似)
pwb_t     = 1.2;                // PWB 厚
conn_w    = 10.1;               // コネクタ部幅
conn_d    = 3.3;                // ( ) コネクタ部奥行

cable_d   = 3.2;                // ケーブル簡易表現
cable_l   = 18;

// -------- 派生 Z レベル --------
z_top      =  total_h/2;        //  +6.75 (レンズ頂面)
z_case_top =  z_top - turret_h; //  +4.05 (ケース上面)
z_bot      = -total_h/2;        //  -6.75 (ケース底面)
z_bar_bot  =  z_bot - bar_h;    // -12.15 (バー底面)

turret_yc  = body_w/2 - turret_setb - turret_d/2;  // 突起のY中心
conn_cx    = bar_x0 + bar_w/2;                     // ケーブル取出しX

// ---------------- 部品モジュール ----------------

// 取付タブ (本体側面から張り出す耳 / φ3.2 穴)
module mount_tab(s) {
    hull() {
        translate([s*hole_pitch/2, 0, 0])
            rotate([90, 0, 0])
                cylinder(r = tab_r, h = tab_t, center = true);
        translate([s*(body_l/2 - 0.5), 0, 0])
            cube([1, tab_t, 2*tab_r], center = true);
    }
}

// レンズ突起 (上面ターレット)
module lens_turret(x0, w) {
    translate([x0, turret_yc - turret_d/2, z_bot])
        cube([w, turret_d, total_h]);
}

// ---------------- 本体組立 ----------------
module gp2y0a21yk0f() {
    union() {
        difference() {
            union() {
                // --- 本体ケース ---
                translate([0, 0, (z_case_top + z_bot)/2])
                    cube([body_l, body_w, case_h], center = true);

                // --- レンズ突起 (発光側 / 受光側) ---
                lens_turret(-body_l/2, em_turret_w);
                lens_turret(-body_l/2 + em_turret_w + turret_gap,
                            det_turret_w);

                // --- 取付タブ x2 ---
                for (s = [-1, 1]) mount_tab(s);

                // --- 連結バー (下方向の延長部) ---
                translate([bar_x0, -bar_d/2, z_bar_bot])
                    cube([bar_w, bar_d, bar_h + 1]);

                // --- PWB (薄板, 参考表現) ---
                translate([bar_x0 + 0.5, -pwb_t/2, z_bar_bot + 0.5])
                    cube([bar_w - 1, pwb_t, bar_h]);

                // --- コネクタ部の張り出し ---
                translate([conn_cx, 0, z_bar_bot + 1.5])
                    cube([conn_w, conn_d + pwb_t, 3], center = true);
            }

            // --- 取付穴 φ3.2 x2 (Y方向貫通) ---
            for (s = [-1, 1])
                translate([s*hole_pitch/2, 0, 0])
                    rotate([90, 0, 0])
                        cylinder(d = hole_d, h = body_w + 10, center = true);

            // --- ケーブル取り出しの切欠き (バー底の U 溝) ---
            translate([conn_cx, 0, z_bar_bot + 1])
                cube([cable_d + 1, bar_d + conn_d + 4, 2.2], center = true);
        }

        // --- 発光側レンズ (円形窓) ---
        translate([em_cx, turret_yc, z_top])
            cylinder(d = 5.5, h = 0.6);
        translate([em_cx, turret_yc, z_top + 0.6])
            scale([1, 1, 0.35]) sphere(d = 5.5);

        // --- 受光側レンズ (矩形窓 + 内側円形レンズ) ---
        translate([det_cx, turret_yc, z_top + 0.25])
            cube([8.0, 5.2, 0.5], center = true);
        translate([det_cx, turret_yc, z_top + 0.5])
            scale([1, 1, 0.35]) sphere(d = 4.5);

        // --- ケーブル (JST PHR-3 への引き出し / 丸棒で簡易表現) ---
        translate([conn_cx, 0, z_bar_bot - cable_l + 1])
            cylinder(d = cable_d, h = cable_l);
    }
}

gp2y0a21yk0f();