/* =====================================================================
   SHARP GP2Y0D413K0F  距離センサ  外形モデル
   Data sheet "Outline Dimensions" (2ページ目) の寸法に基づく簡易モデル
   単位 : mm
   座標系 : 本体ケース(Carbonic ABS)のバウンディングボックス中心を原点
            +X : 右, +Y : 前面(レンズ側), +Z : 上
   ※ 図面に明記されていない奥行き・レンズ形状等は
      他の寸法・全体バランスから妥当な値を仮定している
      （コメントに "assumed" と記載）
   ===================================================================== */

$fn = 60;

// ---------------------------------------------------------------
// 1. 図面から読み取った寸法
// ---------------------------------------------------------------
case_width     = 29.45;   // 本体幅 (X)  [図示]
case_height    = 13.05;   // 本体全高 (Z, foot含む) [図示]
foot_height    = 3.75;    // 下部の細くなった部分の高さ [図示]
foot_width     = 10.1;    // 同上の幅 [図示]
upper_height   = case_height - foot_height; // 9.3  上部本体の高さ

lens_case_depth  = 7.1;   // レンズケース突出量 (Y) [図示 7.1±0.1]
lens_case_height = 8.4;   // レンズケースの高さ (Z) [図示]

// 奥行き方向は下面図の 3 区間(7.5 / 4.15 / 16.3)・13.5 から推定 (assumed)
case_depth   = 16.3;      // 上部本体の奥行き (Y)   [下面図の値を採用]
foot_depth   = 13.5;      // foot / PWB の奥行き (Y) [下面図の値]

// レンズ中心位置 ( "*" 参照寸法 )
emitter_x  = -case_width/2 + 4.5;   // *4.5
detector_x = -case_width/2 + 19.7;  // *19.7

// レンズ形状(図に明記なし、概形のみなので assumed)
emitter_d      = 6.5;   // 発光部(円形)レンズ 直径
detector_w     = 8.0;   // 受光部(矩形)レンズ 幅
detector_h     = 6.0;   // 受光部(矩形)レンズ 高さ
lens_protrude  = 1.0;   // レンズ窓の前方への出っ張り量(視認用)

// PWB
pwb_thickness = 1.2;     // [図示]
pwb_width     = foot_width;   // assumed: foot と同幅
pwb_depth     = foot_depth;   // assumed: foot と同奥行き

// コネクタ (JCTC 12001W90-3P-HF) 簡易表現
connector_h  = 3.3;    // (3.3) 参考寸法 = コネクタ本体高さ
connector_w  = 7.5;    // 下面図の値を流用 (assumed)
connector_d  = 4.15;   // 下面図の値を流用 (assumed)
pin_length   = 18.9 - (case_height + pwb_thickness + connector_h); // 端子長さ(全高18.9に合わせる)
pin_d        = 0.6;    // ピン直径 (assumed)
pin_pitch    = 2.0;    // ピン間隔   (assumed)

// ---------------------------------------------------------------
// 2. Z 方向基準位置 (本体ケース中心を原点とするための計算)
// ---------------------------------------------------------------
case_top_z    = case_height/2;                 // = 6.525
case_bottom_z = -case_height/2;                // = -6.525
upper_bottom_z= case_top_z - upper_height;      // 上部ブロック下端 = -2.775

pwb_top_z     = case_bottom_z;
pwb_bottom_z  = pwb_top_z - pwb_thickness;

conn_top_z    = pwb_bottom_z;
conn_bottom_z = conn_top_z - connector_h;

pin_top_z     = conn_bottom_z;
pin_bottom_z  = pin_top_z - pin_length;

lens_case_top_z    = case_top_z;                 // レンズケースは本体上面と面一
lens_case_bottom_z = lens_case_top_z - lens_case_height;
lens_center_z      = (lens_case_top_z + lens_case_bottom_z)/2;

case_front_y = case_depth/2;                    // 本体前面 Y座標
lens_case_front_y = case_front_y + lens_case_depth;

// ---------------------------------------------------------------
// 3. 部品モジュール
// ---------------------------------------------------------------

// ---- 本体ケース (Carbonic ABS) : 上部ブロック + 下部foot ----
module main_case() {
    color("dimgray") {
        // 上部ブロック
        translate([-case_width/2, -case_depth/2, upper_bottom_z])
            cube([case_width, case_depth, upper_height]);

        // 下部の細い foot
        translate([-foot_width/2, -foot_depth/2, case_bottom_z])
            cube([foot_width, foot_depth, foot_height]);
    }
}

// ---- レンズケース (前面に飛び出す突起) ----
module lens_case() {
    color("dimgray")
        translate([-case_width/2, case_front_y, lens_case_bottom_z])
            cube([case_width, lens_case_depth, lens_case_height]);
}

// ---- 発光部レンズ (円形窓・左側) ----
module emitter_lens() {
    color("orange")
        translate([emitter_x, lens_case_front_y, lens_center_z])
            rotate([90,0,0])
                cylinder(d = emitter_d, h = lens_protrude);
}

// ---- 受光部レンズ (矩形窓・右側) ----
module detector_lens() {
    color("orange")
        translate([detector_x - detector_w/2,
                    lens_case_front_y,
                    lens_center_z - detector_h/2])
            cube([detector_w, lens_protrude, detector_h]);
}

// ---- PWB (プリント基板) ----
module pwb() {
    color("burlywood")
        translate([-pwb_width/2, -pwb_depth/2, pwb_bottom_z])
            cube([pwb_width, pwb_depth, pwb_thickness]);
}

// ---- 3ピンコネクタ (JCTC 12001W90-3P-HF, 簡易表現) ----
module connector() {
    color("black") {
        // コネクタ本体
        translate([-connector_w/2, -connector_d/2, conn_bottom_z])
            cube([connector_w, connector_d, connector_h]);

        // 3本のピン (①②③)
        for (i = [-1, 0, 1]) {
            translate([i*pin_pitch, 0, pin_bottom_z])
                cylinder(d = pin_d, h = pin_length);
        }
    }
}

// ---------------------------------------------------------------
// 4. アセンブリ
// ---------------------------------------------------------------
module GP2Y0D413K0F() {
    main_case();
    lens_case();
    emitter_lens();
    detector_lens();
    pwb();
    connector();
}

GP2Y0D413K0F();