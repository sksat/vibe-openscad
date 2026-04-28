// L-Bracket (L字金具)
// 内側コーナーが原点、水平面は+Y方向、垂直面は+Z方向

width      = 50;   // 幅 (X方向)
fl_horiz   = 40;   // 水平フランジ奥行き (Y方向)
fl_vert    = 40;   // 垂直フランジ高さ (Z方向)
t          = 3;    // 板厚
hole_d     = 4.5;  // 貫通穴径
cs_d       = 8;    // 皿座面径
cs_dep     = 2;    // 皿座面深さ
inset      = 10;   // 縁からの距離
eps        = 0.01; // 干渉回避用微小値

// 穴のX位置(左右対称、中心線から±15mm)
hole_xs = [width/2 - (width/2 - inset), width/2 + (width/2 - inset)];
// = [10, 40]

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
        // 外側 = 下面(Z = -t)、穴は下から上(+Z)へ開ける
        // Y方向: 縁(Y=fl_horiz)から inset 内側 → Y = fl_horiz - inset = 30
        for (x = hole_xs) {
            translate([x, fl_horiz - inset, -t - eps]) {
                // 貫通穴(下から上へ)
                cylinder(d=hole_d, h=t + 2*eps, $fn=48);
                // 皿座面: 外側(下面)から内側へ cs_dep 掘る
                // 下端(Z=0相当)が大径(cs_d)、上が小径(hole_d)
                cylinder(d1=cs_d, d2=hole_d, h=cs_dep + eps, $fn=48);
            }
        }

        // --- 垂直面の皿穴 ---
        // 外側 = 前面(Y = -t)、穴は前(-Y)から後(+Y)へ開ける
        // Z方向: 縁(Z=fl_vert)から inset 内側 → Z = fl_vert - inset = 30
        for (x = hole_xs) {
            translate([x, -t - eps, fl_vert - inset]) {
                rotate([-90, 0, 0]) {
                    // 貫通穴(前から後へ)
                    cylinder(d=hole_d, h=t + 2*eps, $fn=48);
                    // 皿座面: 外側(前面)から内側へ cs_dep 掘る
                    cylinder(d1=cs_d, d2=hole_d, h=cs_dep + eps, $fn=48);
                }
            }
        }
    }
}

l_bracket();