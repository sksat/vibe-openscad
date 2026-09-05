// ============================================================
// Sharp GP2Y0A21YK0F 距離測定センサ
// 単位: mm / 本体中心を原点 / 取付面(PWB/コネクタ)は -Z
// ============================================================

$fn = 48;

// ---- 主要寸法 ----
lens_case_w   = 29.5;   // レンズケース幅
lens_case_h   = 13.5;   // 本体高さ(Y方向)
body_depth    = 13;     // 奥行(Z方向 上部レンズケース)
lens_pitch    = 20;     // レンズ中心間
lens_dia      = 7.5;    // レンズ外径
lens_case_x1  = 4.5;    // 左レンズ中心オフセット(片側)

mount_span    = 37;     // 取付穴中心間距離
hole_dia      = 3.2;    // 取付穴径
ear_r         = 3.75;   // 耳部半径 R3.75
ear_z_off     = 1.5;    // 耳の厚み中心付近

pwb_depth     = 1.2;    // PWB厚
pwb_h         = 13.5;   // PWB高さ

// レンズ突出量: 18.9 - 13 = 5.9mm 相当
lens_protrude = 5.9;

// ============================================================
// 本体レンズケース (Carbonic ABS)
// Z: -body_depth/2 .. +body_depth/2, レンズは +Z 側
// ============================================================
module lens_case() {
    color([0.25,0.25,0.25]) {
        // メインブロック
        translate([0,0,0])
            cube([lens_case_w, lens_case_h, body_depth], center=true);
    }
}

// ============================================================
// レンズ (Acrylic 黒/可視光カット)
// ============================================================
module lens(cx) {
    color([0.1,0.1,0.12]) {
        // レンズ収容円筒(前面)
        translate([cx, 0, body_depth/2])
            cylinder(h=lens_protrude*0.4, d=lens_dia+1.5);
        // レンズ本体(ドーム)
        translate([cx, 0, body_depth/2 + lens_protrude*0.4]) {
            cylinder(h=lens_protrude*0.4, d=lens_dia);
            translate([0,0,lens_protrude*0.4])
                scale([1,1,0.6]) sphere(d=lens_dia);
        }
    }
}

// ============================================================
// 取付耳 (両側の R3.75 + φ3.2 穴)
// ============================================================
module mounting_ear(x) {
    ear_thick = 3.0;
    color([0.25,0.25,0.25])
    translate([x, 0, -body_depth/2 + ear_thick/2 + 1])
    difference() {
        // 耳外形
        hull() {
            cylinder(h=ear_thick, r=ear_r, center=true);
            translate([-sign(x)*4,0,0])
                cylinder(h=ear_thick, r=ear_r, center=true);
        }
        // 取付穴
        cylinder(h=ear_thick+1, d=hole_dia, center=true);
    }
}

// ============================================================
// PWB (Paper phenol) 取付面 -Z 側
// ============================================================
module pwb() {
    pwb_w = 14.75; // PWB幅(概略)
    color([0.15,0.4,0.15])
    translate([0, 0, -body_depth/2 - pwb_depth/2])
        cube([pwb_w, pwb_h, pwb_depth], center=true);
}

// ============================================================
// コネクタ (JCTC 12001W90-3P-HF) 3ピン
// PWBから -Z 方向に突出
// ============================================================
module connector() {
    conn_w = 10.1;   // コネクタ幅(概略)
    conn_h = 4.15;   // 高さ方向
    conn_d = 4.0;    // 突出量
    // ハウジング
    color([0.9,0.9,0.9])
    translate([0, -pwb_h/2 + conn_h/2,
               -body_depth/2 - pwb_depth - conn_d/2])
        cube([conn_w, conn_h, conn_d], center=true);

    // 3本のピン
    color([0.8,0.7,0.2])
    for (i = [-1:1]) {
        translate([i*2.54, -pwb_h/2 + conn_h/2,
                   -body_depth/2 - pwb_depth - conn_d - 1.0])
            cube([0.6, 0.6, 2.0], center=true);
    }
}

// ============================================================
// 組み立て
// ============================================================
module gp2y0a21() {
    lens_case();

    // 2つのレンズ (発光 / 受光), ピッチ20mm 中央に配置
    lens(-lens_pitch/2);
    lens( lens_pitch/2);

    // 取付耳 (本体幅の外側, 穴中心間 37mm)
    mounting_ear(-mount_span/2);
    mounting_ear( mount_span/2);

    // PWB
    pwb();

    // コネクタ
    connector();
}

gp2y0a21();