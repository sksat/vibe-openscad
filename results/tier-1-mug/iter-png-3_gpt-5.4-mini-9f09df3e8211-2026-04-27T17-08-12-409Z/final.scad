$fn = 128;

outer_d = 80;
height = 100;
wall = 4;
bottom = 6;

handle_major_r = 12;   // リングの中心線半径
handle_tube_r   = 4;   // 取手の断面半径
handle_z        = height * 0.5;

// カップ本体
module mug_body() {
    difference() {
        cylinder(h = height, d = outer_d);
        translate([0, 0, bottom])
            cylinder(h = height - bottom + 0.5, d = outer_d - 2 * wall);
    }
}

// リング状取手
module torus(R, r) {
    rotate_extrude(convexity = 10)
        translate([R, 0, 0])
            circle(r = r);
}

module ring_handle() {
    // 外径80mmの側面から十分にはみ出し、指を通しやすいように配置
    handle_center_x = outer_d / 2 + handle_major_r + handle_tube_r + 2;

    translate([handle_center_x, 0, handle_z])
        rotate([0, 90, 0])
            torus(handle_major_r, handle_tube_r);
}

union() {
    mug_body();
    ring_handle();
}