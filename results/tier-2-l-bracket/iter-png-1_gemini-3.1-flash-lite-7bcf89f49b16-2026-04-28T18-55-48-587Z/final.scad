// パラメータ設定
width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_dia = 4.5;
cs_dia = 8.0;
cs_depth = 2.0;

// 皿穴モジュール（外側から皿座面を彫る）
module hole_h(inverted = false) {
    union() {
        // 貫通穴
        cylinder(d = hole_dia, h = thickness * 2, center = true);
        // 皿座面
        translate([0, 0, inverted ? -thickness/2 + cs_depth/2 : thickness/2 - cs_depth/2])
            cylinder(d = cs_dia, h = cs_depth, center = true, $fn = 32);
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

        // 水平面の穴: 縁から10mm内側 (Y=10とY=30の位置)
        // 水平面の上面(Z=3)側から皿座面を彫るため、invertedをfalseにする
        for (x = [-1, 1]) {
            translate([width / 2 + x * 10, 10 + (depth - 20) / 2, 0])
                hole_h(inverted = false);
        }

        // 垂直面の穴: 縁から10mm内側 (Z=10とZ=30の位置)
        // 垂直面の前面(Y=3)側から皿座面を彫るため、invertedをtrueにする
        for (x = [-1, 1]) {
            translate([width / 2 + x * 10, 0, 10 + (height - 20) / 2])
                rotate([90, 0, 0])
                    hole_h(inverted = true);
        }
    }
}

$fn = 64;
l_bracket();