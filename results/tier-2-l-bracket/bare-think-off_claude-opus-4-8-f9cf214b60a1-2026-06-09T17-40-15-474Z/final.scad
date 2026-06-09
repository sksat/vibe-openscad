// L-bracket with countersunk holes
// 内側コーナーが原点

// パラメータ
width      = 50;   // 幅 (X)
depth      = 40;   // 水平面の奥行き (Y)
height     = 40;   // 垂直面の高さ (Z)
thickness  = 3;    // 板厚

hole_dia   = 4.5;  // 貫通穴 Φ
cs_dia     = 8;    // 皿座面 Φ
cs_depth   = 2;    // 皿座面 深さ
edge_off   = 10;   // 縁からのオフセット
x_off      = 12.5; // 中心線からの左右オフセット

eps = 0.01;

// 皿穴 (Z軸方向に貫通、皿座面は上(+Z)側)
// h: 板厚, 座面は z = h 側(外側)に開く
module countersink(h) {
    // 貫通穴
    translate([0, 0, -eps])
        cylinder(h = h + 2*eps, d = hole_dia, $fn = 48);
    // 皿座面(外側 = +Z 側)
    translate([0, 0, h - cs_depth])
        cylinder(h = cs_depth + eps, d = cs_dia, $fn = 48);
}

difference() {
    union() {
        // 水平面 (+Y 方向に伸びる、厚みは -Z 側)
        translate([0, 0, -thickness])
            cube([width, depth, thickness]);
        // 垂直面 (+Z 方向に伸びる、厚みは -Y 側)
        translate([0, -thickness, 0])
            cube([width, thickness, height]);
    }

    // --- 水平面の穴 (外側 = 下面 -Z) ---
    // 水平面の板は z: -thickness .. 0
    // 座面を下側(-Z, 外側)に向けるため反転して配置
    for (dx = [-x_off, x_off]) {
        translate([width/2 + dx, depth - edge_off, 0])
            rotate([180, 0, 0])
                countersink(thickness);
    }

    // --- 垂直面の穴 (外側 = -Y 面) ---
    // 垂直面の板は y: -thickness .. 0
    // 座面を -Y(外側)に向けるため X軸まわりに回転して配置
    for (dx = [-x_off, x_off]) {
        translate([width/2 + dx, 0, height - edge_off])
            rotate([90, 0, 0])
                countersink(thickness);
    }
}