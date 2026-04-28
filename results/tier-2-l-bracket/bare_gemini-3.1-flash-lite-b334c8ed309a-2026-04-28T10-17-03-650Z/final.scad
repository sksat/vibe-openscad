// パラメータ設定
width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_dia = 4.5;
cs_dia = 8.0;
cs_depth = 2.0;

module hole() {
    union() {
        cylinder(d = hole_dia, h = thickness * 2, center = true);
        translate([0, 0, thickness / 2 - cs_depth + 0.01])
            cylinder(d = cs_dia, h = cs_depth, $fn = 32);
    }
}

module l_bracket() {
    difference() {
        union() {
            // 水平面
            cube([width, depth, thickness]);
            // 垂直面
            cube([width, thickness, height]);
        }

        // 水平面の穴
        for (x = [-1, 1]) {
            translate([width / 2 + x * 15, 10 + (depth - 10) / 2, -thickness])
                hole();
        }

        // 垂直面の穴
        for (x = [-1, 1]) {
            translate([width / 2 + x * 15, thickness + 1, 10 + (height - 10) / 2])
                rotate([90, 0, 0])
                    hole();
        }
    }
}

$fn = 64;
l_bracket();