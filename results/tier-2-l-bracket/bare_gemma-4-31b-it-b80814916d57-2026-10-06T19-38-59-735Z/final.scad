// Parameters
width = 50;          // 幅
depth = 40;          // 奥行き (水平面)
height = 40;         // 高さ (垂直面)
thickness = 3;       // 板厚
hole_d = 4.5;        // 貫通穴径 (M4)
cs_d = 8;            // 皿座面径
cs_h = 2;            // 皿座面深さ
offset = 10;         // 縁からの距離
$fn = 64;            // 円の分割数

// 皿穴モジュール
module countersunk_hole() {
    union() {
        // 貫通穴 (板厚より少し長く設定して確実に貫通させる)
        cylinder(d = hole_d, h = thickness + 1);
        // 皿座面 (外側に向かって広がる形状)
        translate([0, 0, -cs_h])
            cylinder(d1 = hole_d, d2 = cs_d, h = cs_h);
    }
}

difference() {
    // 本体形状
    union() {
        // 水平面 (原点から+Y方向に伸び、厚み方向は-Z)
        translate([-width/2, 0, -thickness])
            cube([width, depth, thickness]);
        
        // 垂直面 (原点から+Z方向に伸び、厚み方向は-Y)
        translate([-width/2, -thickness, 0])
            cube([width, thickness, height]);
    }

    // 皿穴の配置
    // 水平面の穴 (底面 Z = -thickness が外側)
    translate([0, offset, -thickness])
        countersunk_hole();
    translate([0, depth - offset, -thickness])
        countersunk_hole();

    // 垂直面の穴 (背面 Y = -thickness が外側)
    // X軸周りに90度回転させて配置
    translate([0, -thickness, offset])
        rotate([90, 0, 0])
            countersunk_hole();
    translate([0, -thickness, height - offset])
        rotate([90, 0, 0])
            countersunk_hole();
}