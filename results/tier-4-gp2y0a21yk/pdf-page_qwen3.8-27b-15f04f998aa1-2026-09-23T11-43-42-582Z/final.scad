// Sharp GP2Y0A21YK0F 赤外線測距センサ
// データシート "Outline Dimensions" (Unit: mm) からの概略モデリング
//
// 座標系: 単位 mm。原点 = 本体中心
//         X = 幅方向, Y = 高さ方向, Z = 光軸
//         +Z = レンズ面(発光/受光), -Z = PWB / コネクタ側(取付面)

// ---------------- パラメータ ----------------
body_w  = 29.5;             // 本体幅
body_h  = 11.0;             // 本体高（側面プロファイルより概算）
body_d  = 8.4;              // 本体奥行き（前面-背面）

overall_w = 37.0;           // 取付タブ含む全幅
tab_h   = 3.0;              // 取付タブ高さ
tab_thk = 1.6;              // 取付タブ厚み（概算）
tab_xo  = overall_w / 2;   // タブ外側端 (18.5)
hole_d  = 3.2;              // 取付穴径 (phi3.2)
hole_x  = 16.25;            // 取付穴中心 X（概算）

em_x  = -body_w/2 + 4.5;    // Light emitter 中心  (-10.25)
det_x = em_x + 20.0;        // Light detector 中心 (+9.75), 間隔 20 ±0.1
lens_r  = 2.5;              // レンズ半径（概算）

case_w = 8.0;               // レンズケース幅（detector 側）
case_h = 6.0;               // レンズケース高
case_d = 2.0;               // レンズケース突出量

pwb_w   = 10.1;             // PWB タブ幅
pwb_thk = 1.2;              // PWB 厚み
pwb_len = 6.35;             // PWB の本体背面からの突出 (14.75 - 8.4)

// ---------------- 本体 ----------------
$fn = 48;

difference() {
  union() {
    // 本体
    cube([body_w, body_h, body_d], center = true);

    // 取付タブ（前面 +Z、左右）
    for (sx = [-1, 1])
      translate([sx * (body_w/2 + (tab_xo - body_w/2)/2), 0,
                 body_d/2 - tab_thk/2])
        cube([tab_xo - body_w/2, tab_h, tab_thk], center = true);

    // レンズケース（detector 側、前面 +Z）
    translate([det_x, 0, body_d/2 + case_d/2])
      cube([case_w, case_h, case_d], center = true);

    // Light emitter レンズ（本体前面に突出）
    translate([em_x, 0, body_d/2])
      cylinder(h = 0.8, d = lens_r*2);

    // Light detector レンズ（ケース上に突出）
    translate([det_x, 0, body_d/2 + case_d])
      cylinder(h = 0.8, d = lens_r*2);

    // PWB タブ（背面 -Z）
    translate([0, 0, -body_d/2 - pwb_len/2])
      cube([pwb_w, pwb_thk, pwb_len], center = true);

    // コネクタ用ピン ①②③（PWB 端面部）
    for (i = [-1, 0, 1])
      translate([i*2.5, 0, -body_d/2 - pwb_len - 0.2])
        cube([1.0, pwb_thk + 0.4, 0.5], center = true);
  }

  // 取付穴 phi3.2（タブを Z 方向に貫通）
  for (sx = [-1, 1])
    translate([sx*hole_x, 0, body_d/2 - tab_thk - 0.5])
      cylinder(h = tab_thk + 1.0, d = hole_d);
}