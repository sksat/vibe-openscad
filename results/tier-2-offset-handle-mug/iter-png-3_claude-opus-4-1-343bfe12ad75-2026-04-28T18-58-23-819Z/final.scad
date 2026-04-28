$fn = 100;

// マグカップ本体
union() {
    difference() {
        // 外側の円筒
        cylinder(h = 90, r = 40, center = false);
        // 内側をくり抜く
        translate([0, 0, 6])
            cylinder(h = 90, r = 35, center = false);
    }

    // 取手（+X方向）
    translate([37, 0, 45]) {
        difference() {
            // 取手の外側形状（D字型）
            hull() {
                // 本体側の接続部分（太めにして確実に接続）
                translate([0, -6, -17.5])
                    cube([6, 12, 35]);
                // 外側の半円部分
                translate([20, 0, 0])
                    rotate([90, 0, 0])
                        cylinder(h = 12, r = 17.5, center = true);
            }
            // 取手の内側をくり抜く（高さ30mm × 幅25mm）
            hull() {
                translate([3, -7, -15])
                    cube([1, 14, 30]);
                translate([20, 0, 0])
                    rotate([90, 0, 0])
                        cylinder(h = 14, r = 15, center = true);
            }
        }
    }
}