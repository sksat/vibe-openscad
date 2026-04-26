$fn = 100;

// マグカップ本体
difference() {
    // 外側の円柱
    cylinder(h = 100, r = 40, center = false);
    
    // 内側をくり抜く
    translate([0, 0, 6])
        cylinder(h = 100, r = 36, center = false);
}

// 取手
translate([40, 0, 50]) {
    rotate([90, 0, 0]) {
        difference() {
            // 取手の外側リング
            cylinder(h = 12, r = 35, center = true);
            
            // 取手の内側をくり抜く
            cylinder(h = 13, r = 23, center = true);
            
            // カップ本体との接続部分をカット
            translate([-40, 0, 0])
                cube([40, 80, 14], center = true);
        }
    }
}