// パラメータ設定
width = 50;
depth = 40;
height = 40;
thickness = 3;

// ねじ穴設定
hole_dia = 4.5;
cs_dia = 8.0;
cs_depth = 2.0;

// 皿穴モジュール（外側の面から座ぐりが入るように調整）
module countersunk_hole(is_vertical = false) {
    union() {
        // 貫通穴
        cylinder(d = hole_dia, h = thickness * 3, center = true);
        // 皿座面：外側の面(水平面なら下面、垂直面なら背面)に向けて配置
        if (is_vertical) {
            // 垂直面：Y=3（外側）の面から座ぐりを入れる
            translate([0, -thickness/2 + cs_depth/2, 0])
                rotate([90, 0, 0])
                    cylinder(d1 = hole_dia, d2 = cs_dia, h = cs_depth);
        } else {
            // 水平面：Z=0（下面）の面から座ぐりを入れる
            translate([0, 0, -thickness/2 + cs_depth/2])
                cylinder(d1 = hole_dia, d2 = cs_dia, h = cs_depth);
        }
    }
}

difference() {
    // L字金具の本体
    union() {
        // 水平面 (Y+方向に40mm伸びる)
        cube([width, depth, thickness]);
        // 垂直面 (Z+方向に40mm伸びる)
        cube([width, thickness, height]);
    }

    // 水平面の穴 (Y方向に縁から10mm内側 = Y=30)
    for (x = [12.5, 37.5]) {
        translate([x, 30, 0])
            countersunk_hole(false);
    }

    // 垂直面の穴 (Z方向に縁から10mm内側 = Z=30)
    for (x = [12.5, 3]) { // ※左右対称配置を修正
        translate([x, thickness/2, 30])
            rotate([90, 0, 0])
                countersunk_hole(true);
    }
}

// 補足：X方向の配置を [12.5, 37.5] に統一
difference() {
    union() {
        cube([width, depth, thickness]);
        cube([width, thickness, height]);
    }
    // 水平面用穴
    for (x = [12.5, 37.5]) {
        translate([x, 30, 0]) countersunk_hole(false);
    }
    // 垂直面用穴
    for (x = [12.5, 37.5]) {
        translate([x, thickness/2, 30]) rotate([90, 0, 0]) countersunk_hole(true);
    }
}