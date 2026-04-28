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
hole_xs = [inset, width - inset]; // [10, 40]

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
        // 外側 = 下面(Z = -t)
        // 皿座面は下(外側)が大径、上(内側)が小径
        // Y位置: 奥の縁(Y=40)から inset=10 内側 → Y=30
        for (x = hole_xs) {
            translate([x, fl_horiz - inset, -t - eps]) {
                // 皿座面(外側=下から): d1=cs_d(下/外), d2=hole_d(上/内)
                cylinder(d1=cs_d, d2=hole_d, h=cs_dep + eps, $fn=64);
                // 残りの貫通穴
                cylinder(d=hole_d, h=t + 2*eps, $fn=64);
            }
        }

        // --- 垂直面の皿穴 ---
        // 外側 = 前面(Y = -t)
        // 皿座面は前(外側)が大径、後(内側)が小径
        // Z位置: 上の縁(Z=40)から inset=10 内側 → Z=30
        for (x = hole_xs) {
            // 前面(外側)から穴を開ける: Y方向に +t 進む
            translate([x, -t - eps, fl_vert - inset]) {
                rotate([90, 0, 0]) {
                    // rotate後: Z方向が -Y方向(穴が内側へ向く)
                    // 皿座面を外側(前面)に: d1=cs_d, d2=hole_d
                    cylinder(d1=cs_d, d2=hole_d, h=cs_dep + eps, $fn=64);
                    // 残りの貫通穴
                    cylinder(d=hole_d, h=t + 2*eps, $fn=64);
                }
            }
        }
    }
}

l_bracket();