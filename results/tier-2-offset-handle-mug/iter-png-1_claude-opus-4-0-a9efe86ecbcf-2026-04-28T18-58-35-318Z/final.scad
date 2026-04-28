$fn = 100;

// マグカップ本体
difference() {
    // 外側の円筒
    cylinder(h = 90, r = 40, center = false);
    // 内側をくり抜く
    translate([0, 0, 6])
        cylinder(h = 84, r = 35, center = false);
}

// 取手
difference() {
    // 取手の外形
    hull() {
        // マグ本体との接続部分（上）
        translate([38, 0, 60])
            rotate([90, 0, 0])
                cylinder(h = 8, r = 5, center = true);
        // マグ本体との接続部分（下）
        translate([38, 0, 30])
            rotate([90, 0, 0])
                cylinder(h = 8, r = 5, center = true);
        // 取手の外側の頂点
        translate([55, 0, 45])
            rotate([90, 0, 0])
                cylinder(h = 8, r = 5, center = true);
    }
    
    // 取手の穴（D字形の内側）
    hull() {
        // 上部の穴
        translate([45, 0, 57.5])
            rotate([90, 0, 0])
                cylinder(h = 10, r = 2.5, center = true);
        // 下部の穴
        translate([45, 0, 32.5])
            rotate([90, 0, 0])
                cylinder(h = 10, r = 2.5, center = true);
        // 外側の穴
        translate([55, 0, 45])
            rotate([90, 0, 0])
                cylinder(h = 10, r = 12.5, center = true);
    }
}