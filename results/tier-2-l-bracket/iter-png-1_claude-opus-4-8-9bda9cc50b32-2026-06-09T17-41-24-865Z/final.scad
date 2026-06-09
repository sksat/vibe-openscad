// L-bracket with countersunk holes

// パラメータ
width      = 50;   // 幅 (X方向)
depth      = 40;   // 水平面の奥行き / 垂直面の高さ
thickness  = 3;    // 板厚

hole_d     = 4.5;  // 貫通穴径 M4
cs_d       = 8;    // 皿座面径
cs_depth   = 2;    // 皿座面深さ
edge_off   = 10;   // 面の縁からの距離

// 穴中心のX座標（面の中心線X=25に対して左右対称）
x1 = width/2 - 12.5;   // 12.5
x2 = width/2 + 12.5;   // 37.5

// 皿穴モジュール（+Z方向に貫通、上面=外側に円錐の皿座）
module countersunk_hole(plate_thickness) {
    // 貫通穴
    translate([0, 0, -1])
        cylinder(h = plate_thickness + 2, d = hole_d, $fn = 48);
    // 皿座（円錐テーパー、上面=外側に向け広がる）
    translate([0, 0, plate_thickness - cs_depth])
        cylinder(h = cs_depth, d1 = hole_d, d2 = cs_d, $fn = 48);
    // 念のため外側を少し抜く
    translate([0, 0, plate_thickness - 0.001])
        cylinder(h = 1, d = cs_d, $fn = 48);
}

module l_bracket() {
    difference() {
        union() {
            // 水平面 (+Y方向に伸びる)
            cube([width, depth, thickness]);
            // 垂直面 (+Z方向に伸びる)
            cube([width, thickness, depth]);
        }

        // --- 水平面の皿穴 (外側 = -Z 側) ---
        // Y位置: 縁(Y=depth)から10mm内側 -> Y = depth - edge_off
        for (x = [x1, x2]) {
            translate([x, depth - edge_off, thickness])
                rotate([180, 0, 0])
                    countersunk_hole(thickness);
        }

        // --- 垂直面の皿穴 (外側 = -Y 側) ---
        // Z位置: 縁(Z=depth)から10mm内側 -> Z = depth - edge_off
        for (x = [x1, x2]) {
            translate([x, thickness, depth - edge_off])
                rotate([90, 0, 0])
                    countersunk_hole(thickness);
        }
    }
}

l_bracket();