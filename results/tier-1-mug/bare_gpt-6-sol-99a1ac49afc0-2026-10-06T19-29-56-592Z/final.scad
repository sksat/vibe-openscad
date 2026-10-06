$fn = 96;

difference() {
    union() {
        // カップ本体
        cylinder(d = 80, h = 100);

        // 側面のリング状取手
        translate([52, 0, 50])
            rotate([90, 0, 0])
                rotate_extrude()
                    translate([12, 0, 0])
                        circle(r = 4);
    }

    // 内側をくり抜き、底面を6mm残す
    translate([0, 0, 6])
        cylinder(d = 72, h = 95);
}