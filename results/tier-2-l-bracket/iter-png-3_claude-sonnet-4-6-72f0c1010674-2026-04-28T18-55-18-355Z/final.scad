// L-Bracket (L字金具)
// 内側コーナーが原点、水平面は+Y方向、垂直面は+Z方向

width    = 50;   // 幅 (X方向)
fl_horiz = 40;   // 水平フランジ奥行き (Y方向)
fl_vert  = 40;   // 垂直フランジ高さ (Z方向)
t        = 3;    // 板厚
hole_d   = 4.5;  // 貫通穴径
cs_d     = 8;    // 皿座面径
cs_dep   = 2;    // 皿座面深さ
inset    = 10;   // 縁からの距離
eps      = 0.1;  // 干渉回避用微小値

// 穴のX位置: 幅50mm、縁から10mm内側 → X=10 と X=40
hole_xs = [inset, width - inset];

module countersunk_hole_vertical(depth) {
    // 上から下へ: 皿座面は上(外側=上面)
    translate([0, 0, depth])
        rotate([180, 0, 0]) {
            cylinder(d1=cs_d, d2=hole_d, h=cs_dep + eps, $fn=64);
            translate([0, 0, cs_dep])
                cylinder(d=hole_d, h=depth - cs_dep + eps, $fn=64);
        }
}

module countersunk_hole_horizontal(depth) {
    // 前面(Y=-t)から後方(+Y)へ掘る: 皿座面は前(外側=前面)
    cylinder(d1=cs_d, d2=hole_d, h=cs_dep + eps, $fn=64);
    translate([0, 0, cs_dep])
        cylinder(d=hole_d, h=depth - cs_dep + eps, $fn=64);
}

module l_bracket() {
    difference() {
        union() {
            // 水平面: X[0~50], Y[0~40], Z[-3~0]
            translate([0, 0, -t])
                cube([width, fl_horiz, t]);

            // 垂直面: X[0~50], Y[-3~0], Z[0~40]
            translate([0, -t, 0])
                cube([width, t, fl_vert]);
        }

        // --- 水平面の皿穴 ---
        // 外側 = 上面(Z=0)、穴は上から下へ
        // Y位置: 縁(Y=fl_horiz)から inset 内側 → Y = fl_horiz - inset = 30
        for (x = hole_xs) {
            translate([x, fl_horiz - inset, 0])
                countersunk_hole_vertical(t + 2*eps);
        }

        // --- 垂直面の皿穴 ---
        // 外側 = 前面(Y=-t)、穴は前面から後方(+Y)へ
        // Z位置: 縁(Z=fl_vert)から inset 内側 → Z = fl_vert - inset = 30
        for (x = hole_xs) {
            translate([x, -t - eps, fl_vert - inset])
                rotate([-90, 0, 0])
                    countersunk_hole_horizontal(t + 2*eps);
        }
    }
}

l_bracket();