// パラメータ設定
width = 50;
depth = 40;
height = 40;
thickness = 3;

// ねじ穴設定
hole_dia = 4.5;
cs_dia = 8.0;
cs_depth = 2.0;

module countersunk_hole(is_vertical = false) {
    union() {
        // 貫通穴
        cylinder(d = hole_dia, h = thickness * 3, center = true);
        // 皿座面（外側の面に向けて配置）
        // 水平面なら下側(Z-)、垂直面なら外側(Y-)に座面を配置
        translate([0, 0, is_vertical ? -thickness / 2 + cs_depth / 2 : thickness / 2 - cs_depth / 2])
            cylinder(d1 = hole_dia, d2 = cs_dia, h = cs_depth);
    }
}

difference() {
    // L字金具の本体 (内側コーナーが原点)
    union() {
        // 水平面 (Y+方向に伸びる)
        cube([width, depth, thickness]);
        // 垂直面 (Z+方向に伸びる)
        cube([width, thickness, height]);
    }

    // 水平面の穴 (Y方向に10mm内側、X方向に左右対称)
    // 縁から10mmとは、外端(Y=40)から10mm手前=Y=30の位置
    for (x = [12.5, 37.5]) {
        translate([x, 30, 0])
            rotate([180, 0, 0])
                countersunk_hole(false);
    }

    // 垂直面の穴 (Z方向に10mm内側、X方向に左右対称)
    // 縁から10mmとは、上端(Z=40)から10mm下=Z=30の位置
    for (x = [12.5, 37.5]) {
        translate([x, 0, 30])
            rotate([90, 0, 0])
                countersunk_hole(true);
    }
}