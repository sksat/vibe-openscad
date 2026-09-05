// =========================================================
//  マグカップ（取手は +X 軸方向のみ）
// =========================================================
$fn = 96;

// ---------- 本体パラメータ ----------
outer_d   = 80;                 // 外径
inner_d   = 70;                 // 内径（肉厚 5mm）
mug_h     = 90;                 // 全高
bottom_th = 6;                  // 底の厚み
outer_r   = outer_d / 2;        // 40
inner_r   = inner_d / 2;        // 35

// ---------- 取手パラメータ ----------
hole_w    = 25;                 // 取手内側の空間：幅（X 方向）
hole_h    = 30;                 // 取手内側の空間：高さ（Z 方向）
bar_t     = 9;                  // 取手の太さ（XZ 断面方向）
bar_w     = 12;                 // 取手の幅（Y 方向）
hole_x0   = outer_r + 1;        // 内側空間の開始 X（本体表面のすぐ外側）
embed     = 4;                  // 本体壁への食い込み量（壁厚 5mm 内に収める）
handle_z  = mug_h / 2;          // 取手の高さ中心（マグ中央）

// ---------- 本体（中空円筒） ----------
module body() {
    difference() {
        cylinder(h = mug_h, r = outer_r);
        translate([0, 0, bottom_th])
            cylinder(h = mug_h - bottom_th + 1, r = inner_r);
    }
}

// ---------- D 字の 2D 形状 ----------
// 左端が直線（x=0）、右側が半円。原点は直線部の中央。
module d_profile(w, h) {
    r = h / 2;
    union() {
        translate([0, -h/2]) square([w - r, h]);   // 直線部
        translate([w - r, 0]) circle(r = r);       // 半円部
    }
}

// ---------- 取手の 2D 断面（XZ 平面用） ----------
module handle_profile() {
    difference() {
        intersection() {
            // 外形：内側 D 形状をオフセットして肉付け
            offset(r = bar_t)
                translate([hole_x0, 0]) d_profile(hole_w, hole_h);
            // 本体側は直線でカット（壁の中まで食い込ませる）
            translate([outer_r - embed, -(hole_h/2 + bar_t + 1)])
                square([hole_w + 2*bar_t + 10, hole_h + 2*bar_t + 2]);
        }
        // 内側の空間（高さ 30mm × 幅 25mm）
        translate([hole_x0, 0]) d_profile(hole_w, hole_h);
    }
}

// ---------- 取手（+X 側のみ） ----------
module handle() {
    translate([0, 0, handle_z])
        rotate([90, 0, 0])
            linear_extrude(height = bar_w, center = true)
                handle_profile();
}

// ---------- 完成品 ----------
union() {
    body();
    handle();
}