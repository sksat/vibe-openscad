$fn = 128;

module d_shape(x0, rect_width, radius) {
    union() {
        translate([x0, -radius])
            square([rect_width, 2 * radius]);

        translate([x0 + rect_width, 0])
            circle(r = radius);
    }
}

module handle_profile() {
    difference() {
        // 外形: 幅40mm、高さ40mmのD字形
        d_shape(35, 20, 20);

        // 内側空間: 幅25mm、高さ30mmのD字形
        d_shape(40, 10, 15);
    }
}

union() {
    // 本体: 外径80mm、内径70mm、高さ90mm、底厚6mm
    difference() {
        cylinder(r = 40, h = 90);

        translate([0, 0, 6])
            cylinder(r = 35, h = 90);
    }

    // 取手: +X方向のみ、中央高さに配置
    translate([0, 6, 45])
        rotate([90, 0, 0])
            linear_extrude(height = 12)
                handle_profile();
}