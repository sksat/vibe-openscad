$fn = 100;

// マグカップ本体
difference() {
    // 外側
    cylinder(r = 40, h = 100);
    
    // 内側のくり抜き（底厚 6mm、肉厚 4mm）
    translate([0, 0, 6])
        cylinder(r = 36, h = 100);
}

// 取手（リング状）
translate([42, 0, 50])
    rotate([90, 0, 0])
        rotate_extrude()
            translate([18, 0, 0])
                circle(r = 4);