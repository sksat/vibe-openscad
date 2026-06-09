// マグカップ（取手は +X 方向のみ）

// パラメータ
outer_d   = 80;   // 外径
inner_d   = 70;   // 内径
wall      = (outer_d - inner_d) / 2; // 肉厚 5mm
height    = 90;   // 全体高さ
bottom_th = 6;    // 底厚

outer_r = outer_d / 2; // 40
inner_r = inner_d / 2; // 35

// 取手パラメータ
hole_h   = 30;    // 取手内側の高さ
hole_w   = 25;    // 取手内側の幅
h_thick  = 8;     // 取手の太さ（断面）
handle_z = height / 2; // 取手を高さ中央に

$fn = 96;

// ===== 本体 =====
module body() {
    difference() {
        cylinder(h = height, r = outer_r);
        translate([0, 0, bottom_th])
            cylinder(h = height - bottom_th + 1, r = inner_r);
    }
}

// ===== 取手 =====
// D字形状: 外側半円 + 直線（本体側）
// 押し出し方向は Y、形状は XZ 平面で定義
module handle() {
    // 取手の外形 - 内側の穴
    handle_outer_w = hole_w + 2 * h_thick; // 全体幅
    handle_outer_h = hole_h + 2 * h_thick; // 全体高さ

    // 取手は +X 側に張り出す。
    // 本体表面 (x=outer_r) から外側へ伸びる D 字。
    translate([outer_r - h_thick, 0, handle_z])
    rotate([90, 0, 0]) // XZ断面をY方向に押し出すため
    linear_extrude(height = h_thick, center = true)
    difference() {
        // 外形 D字
        hull() {
            // 本体側（直線部）
            translate([0, -handle_outer_h/2])
                square([1, handle_outer_h]);
            // 外側半円部
            translate([handle_outer_w - handle_outer_h/2, 0])
                circle(d = handle_outer_h);
        }
        // 内側の穴 D字
        hull() {
            translate([h_thick, -hole_h/2])
                square([1, hole_h]);
            translate([h_thick + hole_w - hole_h/2, 0])
                circle(d = hole_h);
        }
    }
}

// ===== 結合 =====
union() {
    body();
    handle();
}