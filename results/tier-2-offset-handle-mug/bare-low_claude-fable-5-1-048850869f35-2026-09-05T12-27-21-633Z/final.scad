// マグカップ(取手は +X 方向)
$fn = 96;

outer_d   = 80;    // 外径
inner_d   = 70;    // 内径
height    = 90;    // 全高
bottom_t  = 6;     // 底の厚み

// 取手パラメータ
handle_gap_h = 30; // 取手内側の高さ
handle_gap_w = 25; // 取手内側の幅(本体表面から)
handle_t     = 8;  // 取手の太さ(断面の幅)
handle_depth = 12; // 取手の厚み(Y方向)
handle_z     = height / 2; // 取手中心の高さ

outer_r = outer_d / 2;

// 本体
module body() {
    difference() {
        cylinder(h = height, d = outer_d);
        translate([0, 0, bottom_t])
            cylinder(h = height, d = inner_d);
    }
}

// 取手の D 字プロファイル(XZ 平面、X: 本体外側方向)
// 本体側は直線、外側は半円
module handle_profile_2d(w, h) {
    // w: 直線部から半円の最外点までの幅, h: 直線部の高さ
    // 半円は直線部の端に接続
    hull() {
        square([0.01, h], center = true);
        translate([w - h / 2, 0]) circle(d = h);
    }
}

module handle() {
    inner_h = handle_gap_h;
    inner_w = handle_gap_w;
    outer_h = inner_h + 2 * handle_t;
    outer_w = inner_w + handle_t;

    // 本体内部に少し食い込ませて確実に union する
    overlap = 3;
    translate([outer_r - overlap, 0, handle_z])
        rotate([90, 0, 0])
            linear_extrude(height = handle_depth, center = true)
                difference() {
                    handle_profile_2d(outer_w + overlap, outer_h);
                    translate([overlap, 0]) handle_profile_2d(inner_w, inner_h);
                }
}

union() {
    body();
    handle();
}