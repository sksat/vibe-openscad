$fn = 64;

// パラメータ
width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_diameter = 4.5;
countersink_diameter = 8;
countersink_depth = 2;
edge_offset = 10;

module countersunk_hole() {
    // 貫通穴
    cylinder(d = hole_diameter, h = thickness + 0.1, center = false);
    // 皿座面
    translate([0, 0, thickness - countersink_depth])
        cylinder(d1 = hole_diameter, d2 = countersink_diameter, h = countersink_depth + 0.1);
}

difference() {
    // L字ブラケット本体
    union() {
        // 水平面
        translate([0, 0, 0])
            cube([width, depth, thickness]);
        // 垂直面
        translate([0, 0, 0])
            cube([width, thickness, height]);
    }
    
    // 水平面の皿穴（外側 = 下面から）
    translate([width/2 - (width/2 - edge_offset), edge_offset, 0]) {
        translate([0, 0, -0.05])
            mirror([0, 0, 1])
            countersunk_hole();
    }
    translate([width/2 + (width/2 - edge_offset), edge_offset, 0]) {
        translate([0, 0, -0.05])
            mirror([0, 0, 1])
            countersunk_hole();
    }
    
    // 垂直面の皿穴（外側 = 前面から）
    translate([width/2 - (width/2 - edge_offset), 0, edge_offset]) {
        rotate([-90, 0, 0])
            translate([0, 0, -0.05])
            mirror([0, 0, 1])
            countersunk_hole();
    }
    translate([width/2 + (width/2 - edge_offset), 0, edge_offset]) {
        rotate([-90, 0, 0])
            translate([0, 0, -0.05])
            mirror([0, 0, 1])
            countersunk_hole();
    }
}