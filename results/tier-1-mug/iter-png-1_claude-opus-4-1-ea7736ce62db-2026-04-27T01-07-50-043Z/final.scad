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
        rotate_extrude() {
            translate([25, 0, 0])
                circle(r = 12);
        }
    }
}