// L-Bracket (L字金具)
// 内側コーナーが原点、水平面は+Y方向、垂直面は+Z方向

// パラメータ
width       = 50;   // 幅 (X方向)
flange_len  = 40;   // 各フランジの長さ (水平:Y方向, 垂直:Z方向)
thickness   = 3;    // 板厚
hole_d      = 4.5;  // 貫通穴径 (M4)
cs_d        = 8;    // 皿座面径
cs_depth    = 2;    // 皿座面深さ
hole_inset  = 10;   // 縁からの距離
hole_offset = width / 2 - hole_inset; // 中心線からの左右オフセット = 15mm

module countersunk_hole(depth, from_outside=true) {
    // 貫通穴
    cylinder(d=hole_d, h=depth + 1, center=false, $fn=32);
    // 皿座面 (外側から)
    if (from_outside) {
        translate([0, 0, depth - cs_depth])
            cylinder(d1=hole_d, d2=cs_d, h=cs_depth + 0.01, $fn=32);
        // 皿座面の上をフラットにカット（面より上には出ない）
    }
}

module l_bracket() {
    difference() {
        union() {
            // 水平面フランジ: X方向 width, Y方向 flange_len, Z方向 thickness
            // Z: -thickness ~ 0, Y: 0 ~ flange_len
            translate([0, 0, -thickness])
                cube([width, flange_len, thickness]);

            // 垂直面フランジ: X方向 width, Y方向 thickness, Z方向 flange_len
            // Y: -thickness ~ 0, Z: 0 ~ flange_len
            translate([0, -thickness, 0])
                cube([width, thickness, flange_len]);
        }

        // --- 水平面の皿穴 (2個) ---
        // 皿座面は外側(Z下面, Z=-thickness) → 穴はZ=-thickness から上向きに開ける
        // 縁から10mm内側: Y方向の縁はY=flange_len → Y = flange_len - hole_inset = 30
        // 左右対称: X = width/2 ± hole_offset = 25 ± 15 → X=10, X=40
        for (x = [width/2 - hole_offset, width/2 + hole_offset]) {
            translate([x, flange_len - hole_inset, -thickness]) {
                // 貫通穴
                cylinder(d=hole_d, h=thickness + 1, $fn=32);
                // 皿座面は外側(下面 Z=-thickness)→ translate Z=0 で下向きに掘る
                // 皿: 下面から cs_depth 掘り上げる → Z=0 から Z=cs_depth まで
                // 皿形状: 下面(Z=0)で径 cs_d, 上(Z=cs_depth)で径 hole_d
                cylinder(d1=cs_d, d2=hole_d, h=cs_depth + 0.01, $fn=32);
            }
        }

        // --- 垂直面の皿穴 (2個) ---
        // 皿座面は外側(Y下面, Y=-thickness) → 穴はY=-thickness から +Y方向に開ける
        // 縁から10mm内側: Z方向の縁はZ=flange_len → Z = flange_len - hole_inset = 30
        // 左右対称: X=10, X=40
        for (x = [width/2 - hole_offset, width/2 + hole_offset]) {
            translate([x, -thickness, flange_len - hole_inset]) {
                // Y方向に穴を開ける → rotate around X
                rotate([-90, 0, 0]) {
                    // 貫通穴
                    cylinder(d=hole_d, h=thickness + 1, $fn=32);
                    // 皿座面は外側(Y=-thickness面)→ Z=0 (外面) から内側へ cs_depth
                    cylinder(d1=cs_d, d2=hole_d, h=cs_depth + 0.01, $fn=32);
                }
            }
        }
    }
}

l_bracket();