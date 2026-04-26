$fn = 128;

outer_d = 80;
height = 100;
wall = 4;
bottom = 6;

handle_r = 12;
handle_tube_r = 4;   // 取手の太さ
handle_z = height * 0.55;
handle_clear = 10;   // カップ外周からの余裕

module mug_body() {
    difference() {
        // 外形
        cylinder(h = height, d = outer_d);

        // 内側のくり抜き
        translate([0, 0, bottom])
            cylinder(h = height - bottom + 0.5, d = outer_d - 2 * wall);
    }
}

module ring_handle() {
    // カップ外周から十分にはみ出すように配置
    handle_center_x = outer_d / 2 + handle_clear + handle_r;

    translate([handle_center_x, 0, handle_z])
        rotate([0, 90, 0])
            torus(handle_r, handle_tube_r);
}

module torus(R, r) {
    rotate_extrude(convexity = 10)
        translate([R, 0, 0])
            circle(r = r);
}

union() {
    mug_body();
    ring_handle();
}