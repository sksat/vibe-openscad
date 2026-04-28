$fn = 100;

// マグカップ本体
difference() {
    // 外側の円筒
    cylinder(h = 90, r = 40, center = false);
    // 内側をくり抜く
    translate([0, 0, 6])
        cylinder(h = 90, r = 35, center = false);
}

// 取手（+X方向）
translate([40, 0, 45]) {
    difference() {
        union() {
            // 取手の外側形状
            rotate([90, 0, 0])
                cylinder(h = 8, r = 30, center = true);
            // 本体との接続部分
            translate([-15, 0, 0])
                cube([15, 8, 40], center = true);
        }
        // 取手の内側をくり抜く
        rotate([90, 0, 0])
            cylinder(h = 10, r = 22, center = true);
        // 本体側を切り取る
        translate([-50, 0, 0])
            cube([50, 20, 80], center = true);
    }
}