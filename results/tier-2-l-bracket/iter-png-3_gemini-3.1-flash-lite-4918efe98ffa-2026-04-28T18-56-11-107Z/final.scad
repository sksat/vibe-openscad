// パラメータ設定
width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_dia = 4.5;
cs_dia = 8.0;
cs_depth = 2.0;

// 皿穴モジュール
// 皿座面が常に外側（プレートの上面または背面）に来るように調整
module countersunk_hole(is_vertical = false) {
    union() {
        // 貫通穴
        cylinder(d = hole_dia, h = thickness * 2, center = true);
        // 皿座面
        translate([0, 0, is_vertical ? -thickness/2 + cs_depth/2 : thickness/2 - cs_depth/2])
            cylinder(d = cs_dia, h = cs_depth, center = true, $fn = 64);
    }
}

module l_bracket() {
    difference() {
        union() {
            // 水平面 (Y方向に40mm)
            cube([width, depth, thickness]);
            // 垂直面 (Z方向に40mm)
            cube([width, thickness, height]);
        }

        // 水平面の穴（上面から掘る）
        // 縁(Y=40)から10mm内側 = Y=30
        for (x = [-10, 10]) {
            translate([width / 2 + x, 30, 0])
                countersunk_hole(is_vertical = false);
        }

        // 垂直面の穴（背面から掘る）
        // 縁(Z=40)から10mm内側 = Z=30
        for (x = [-10, 10]) {
            translate([width / 2 + x, thickness, 30])
                rotate([90, 0, 0])
                    countersunk_hole(is_vertical = true);
        }
    }
}

$fn = 64;
l_bracket();