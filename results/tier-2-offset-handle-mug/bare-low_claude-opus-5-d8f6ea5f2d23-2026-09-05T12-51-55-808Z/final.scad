// ===== Mug with D-shaped handle on +X side =====
$fn = 128;

// --- Parameters ---
outer_d   = 80;   // 外径
inner_d   = 70;   // 内径 (肉厚 5mm)
height    = 90;   // 全高
bottom_th = 6;    // 底面厚み

hole_h    = 30;   // 取手内側の高さ
hole_w    = 25;   // 取手内側の幅 (X方向)
bar       = 8;    // 取手の太さ(断面)
overlap   = 3;    // 本体へのめり込み量

or  = outer_d / 2;
ir  = inner_d / 2;

// 取手の中心高さ(マグ中央)
handle_z = height / 2;

// --- 本体 ---
module body() {
    difference() {
        cylinder(h = height, r = or);
        translate([0, 0, bottom_th])
            cylinder(h = height - bottom_th + 1, r = ir);
    }
}

// --- D字取手 ---
// 外形 D 形状から内側 D 形状を引く。XZ平面上の2D形状を押し出して回転配置。
module d_profile(w, h) {
    // 直線部を x=0 に置き、+x 側へ張り出す D 形状
    hull() {
        translate([0, -h/2 + w/1e9]) square([0.001, h], center = false);
        // 上下の端点を結ぶ直線部
        translate([0,  h/2 - 0.001]) square([0.001, 0.001]);
    }
}

module handle_2d() {
    difference() {
        // 外形: 高さ hole_h+2*bar, 張り出し hole_w+bar
        hull() {
            translate([0, -(hole_h/2 + bar)]) square([0.01, hole_h + 2*bar]);
            translate([hole_w + bar - (hole_h/2 + bar), 0])
                circle(r = hole_h/2 + bar);
        }
        // 内側の穴: 高さ hole_h, 張り出し hole_w
        hull() {
            translate([-1, -hole_h/2]) square([1.01, hole_h]);
            translate([hole_w - hole_h/2, 0]) circle(r = hole_h/2);
        }
    }
}

module handle() {
    // 2D(X:張り出し, Y:高さ)を XZ 平面へ立てる
    translate([or - overlap, 0, handle_z])
        rotate([90, 0, 0])
            linear_extrude(height = bar, center = true)
                handle_2d();
}

// --- 合成 ---
union() {
    body();
    intersection() {
        handle();
        // 本体内部へは入り込ませない(内壁を貫通させない)
        difference() {
            translate([0, 0, -1]) cylinder(h = height + 2, r = or + hole_w + bar + 10);
            translate([0, 0, bottom_th]) cylinder(h = height, r = ir);
        }
    }
}