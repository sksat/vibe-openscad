// Sharp GP2Y0A21YK0F 測距センサ モデル
// 単位: mm, 原点: 本体中心

$fn = 50;

module gp2y0a21yk0f() {
    // メインボディ (幅37 x 奥行13 x 高さ13.5)
    color("DimGray")
    translate([0, 0, 13.5/2])
    cube([37, 13, 13.5], center = true);

    // 取付タブ (両端)
    color("DimGray")
    difference() {
        union() {
            translate([-18.5, 0, 7.2/2])
            cube([2, 13, 7.2], center = true);
            translate([18.5, 0, 7.2/2])
            cube([2, 13, 7.2], center = true);
        }
        // 取付穴
        rotate([90, 0, 0])
        translate([-18.5, 7.2/2, 0]) cylinder(d = 3.2, h = 20, center = true);
        rotate([90, 0, 0])
        translate([18.5, 7.2/2, 0]) cylinder(d = 3.2, h = 20, center = true);
    }

    // レンズケース部分 (凸部)
    color("Black")
    translate([0, -13/2 - 2/2, 13.5 - 7.2/2])
    cube([29.5, 2, 7.2], center = true);

    // レンズ部
    color("DimGray") {
        translate([-10, -7.5, 6.75]) rotate([90, 0, 0]) cylinder(r = 3.75, h = 2);
        translate([10, -7.5, 6.75]) rotate([90, 0, 0]) cylinder(r = 3.75, h = 2);
    }

    // コネクタ部
    color("WhiteSmoke")
    translate([0, 6.5 + 3.3/2, 1.5/2])
    cube([10.1, 3.3, 1.5], center = true);
    
    color("DimGray")
    translate([0, 6.5 + 3.3/2 + 2, 1.5/2])
    cube([14.75, 4, 2], center = true);
}

gp2y0a21yk0f();