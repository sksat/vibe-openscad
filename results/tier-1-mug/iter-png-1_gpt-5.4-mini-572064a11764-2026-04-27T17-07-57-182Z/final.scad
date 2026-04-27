$fn = 128;

outer_d = 80;
height = 100;
wall = 4;
bottom = 6;

handle_ring_r = 12;   // 取手の半径
handle_tube_r = 4;    // 取手の太さ
handle_z = height * 0.5;
handle_clear = 8;     // 外周からのはみ出し量

module mug_body() {
    difference() {
        // 外形
        cylinder(h = height, d = outer_d);

        // 内側のくり抜き（底厚 6mm）
        translate([0, 0, bottom])
            cylinder(h = height - bottom + 0.5, d = outer_d - 2 * wall);
    }
}

module torus(R, r) {
    rotate_extrude(convexity = 10)
        translate([R, 0, 0])
            circle(r = r);
}

module ring_handle() {
    // カップ外周から十分に外側へ配置
    handle_center_x = outer_d / 2 + handle_clear + handle_ring_r;

    translate([handle_center_x, 0, handle_z])
        rotate([0, 90, 0])
            torus(handle_ring_r, handle_tube_r);
}

union() {
    mug_body();
    ring_handle();
}