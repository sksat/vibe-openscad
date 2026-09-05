// ===== Mug with oriented D-shaped handle (+X side only) =====

$fn = 96;

// ---- Body parameters ----
outer_d   = 80;          // 外径
inner_d   = 70;          // 内径 (肉厚 5mm)
height    = 90;          // 全高
bottom_th = 6;           // 底面厚み

outer_r = outer_d / 2;   // 40
inner_r = inner_d / 2;   // 35

// ---- Handle parameters ----
h_open_h  = 30;          // 取手内側の空間 高さ
h_open_w  = 25;          // 取手内側の空間 幅 (径方向)
h_thick   = 8;           // 取手の太さ(上下バー・外側部の厚み)
h_width   = 12;          // 取手の幅 (Y方向)
h_embed   = 4;           // 本体外周へのめり込み量(確実に union するため)

// 取手の高さ方向中心(マグ中央付近)
h_center_z = bottom_th + (height - bottom_th) / 2;

// ---- Body ----
module mug_body() {
    difference() {
        cylinder(h = height, r = outer_r);
        translate([0, 0, bottom_th])
            cylinder(h = height - bottom_th + 1, r = inner_r);
    }
}

// ---- Handle : D shape (flat on body side, round outside) ----
// 2D プロファイルを XZ 平面で作り、Y 方向に押し出す
module handle_profile() {
    // 内側の穴の開始 X(本体外周からわずかに内側へ食い込ませる)
    x0 = outer_r - h_embed;         // 本体に埋まる側の面
    x1 = x0 + h_thick;              // 穴の内側端(手前)
    x2 = x1 + h_open_w;             // 穴の外側端
    x3 = x2 + h_thick;              // 取手の外端

    difference() {
        // 外形:D 字(本体側は直線、外側は半円)
        hull() {
            translate([x0, -(h_open_h / 2 + h_thick)])
                square([1, h_open_h + 2 * h_thick]);
            translate([x2, -(h_open_h / 2)])
                circle(r = h_thick);
            translate([x2,  (h_open_h / 2)])
                circle(r = h_thick);
        }
        // 内側の空間 30(高さ) x 25(幅)
        translate([x1, -h_open_h / 2])
            square([h_open_w, h_open_h]);
    }
}

module handle() {
    translate([0, h_width / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(height = h_width)
                handle_profile();
}

// ---- Assembly ----
union() {
    mug_body();
    translate([0, 0, h_center_z])
        handle();
}