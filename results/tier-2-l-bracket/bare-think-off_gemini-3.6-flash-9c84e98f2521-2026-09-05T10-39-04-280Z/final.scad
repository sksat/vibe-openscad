// パラメータ定義
width = 50;         // 金具の幅 (X方向)
depth = 40;         // 水平面の奥行き (Y方向)
height = 40;        // 垂直面の高さ (Z方向)
thickness = 3;      // 板厚

hole_d1 = 4.5;      // 貫通穴径
hole_d2 = 8.0;      // 皿モミ最大径
hole_cd = 2.0;      // 皿モミ深さ
hole_margin = 10;   // 縁からの距離

$fn = 64;           // 円の描画精度

// 皿穴モジュール (Z=0 から -Z 方向に向かって配置する形状)
module countersunk_hole() {
    translate([0, 0, thickness + 0.1])
        cylinder(d = hole_d1, h = thickness + 0.2);
    translate([0, 0, thickness - hole_cd])
        cylinder(d1 = hole_d1, d2 = hole_d2, h = hole_cd + 0.01);
}

difference() {
    // 1. 基本となるL字形状
    union() {
        // 水平面 (+Y方向、-Z方向に板厚)
        translate([0, 0, -thickness])
            cube([width, depth, thickness]);
        
        // 垂直面 (+Z方向、-X方向に板厚)
        translate([-thickness, 0, 0])
            cube([thickness, depth, height]);
    }

    // 2. 皿穴の配置
    // 水平面の穴 (2箇所)
    translate([hole_margin, depth / 2, 0])
        rotate([0, 180, 0]) countersunk_hole();
    
    translate([width - hole_margin, depth / 2, 0])
        rotate([0, 180, 0]) countersunk_hole();

    // 垂直面の穴 (2箇所)
    translate([0, depth / 2, hole_margin])
        rotate([0, -90, 0]) countersunk_hole();
    
    translate([0, depth / 2, height - hole_margin])
        rotate([0, -90, 0]) countersunk_hole();
}