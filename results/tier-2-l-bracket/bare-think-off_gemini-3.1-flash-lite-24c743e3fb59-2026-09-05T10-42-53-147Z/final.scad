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
        cylinder(d = hole_dia, h = thickness + 0.1, $fn = 32);
        translate([0, 0, thickness - cs_depth + 0.05])
            cylinder(d = cs_dia, h = cs_depth + 0.1, $fn = 32);
    }
}

difference() {
    // L字本体
    union() {
        cube([width, depth, thickness]);
        cube([width, thickness, height]);
    }

    // 水平面の穴
    translate([width / 4, 10, 0]) hole();
    translate([width * 3 / 4, 10, 0]) hole();

    // 垂直面の穴
    rotate([-90, 0, 0])
    translate([0, 10, -thickness]) {
        translate([width / 4, height / 2 + 5, 0]) 
            rotate([90, 0, 0]) hole();
        translate([width * 3 / 4, height / 2 + 5, 0]) 
            rotate([90, 0, 0]) hole();
    }
}