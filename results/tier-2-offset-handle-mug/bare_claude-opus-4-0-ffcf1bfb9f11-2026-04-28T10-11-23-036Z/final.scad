$fn = 100;

// マグカップ本体
difference() {
    // 外側の円筒
    cylinder(h = 90, r = 40, center = false);
    // 内側をくり抜く
    translate([0, 0, 6])
        cylinder(h = 90, r = 35, center = false);
}

// 取手
translate([40, 0, 45]) {
    difference() {
        // 取手の外形
        union() {
            // 半円部分
            rotate([90, 0, 0])
                cylinder(h = 8, r = 20, center = true);
            // 接続部分
            translate([-20, 0, 0])
                cube([20, 8, 40], center = true);
        }
        // 取手の穴
        rotate([90, 0, 0])
            cylinder(h = 10, r = 12.5, center = true);
        // マグ本体との重なり部分を削除
        translate([-45, 0, 0])
            cylinder(h = 100, r = 40, center = true);
    }
}