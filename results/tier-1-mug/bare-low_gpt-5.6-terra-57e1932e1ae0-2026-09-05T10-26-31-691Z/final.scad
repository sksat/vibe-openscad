$fn = 128;

// カップ本体
difference() {
    cylinder(d = 80, h = 100);

    // 内部くり抜き（側面肉厚 4mm、底面厚み 6mm）
    translate([0, 0, 6])
        cylinder(d = 72, h = 95);
}

// リング状取手
translate([48, 0, 50])
    rotate([90, 0, 0])
        rotate_extrude()
            translate([12, 0, 0])
                circle(r = 4, $fn = 48);