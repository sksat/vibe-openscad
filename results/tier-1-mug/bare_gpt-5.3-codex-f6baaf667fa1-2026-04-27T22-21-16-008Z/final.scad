$fn = 128;

// Dimensions
outer_d = 80;
outer_r = outer_d / 2;
height = 100;
wall_t = 4;
bottom_t = 6;

inner_d = outer_d - 2 * wall_t;
inner_r = inner_d / 2;
inner_h = height - bottom_t;

// Handle (ring)
handle_tube_r = 12;                 // 半径12mmのリング断面
handle_center_offset = outer_r + 20; // カップ外周から十分にはみ出す位置
handle_z = height / 2;              // 中心高さ付近

module mug_body() {
    difference() {
        cylinder(h = height, r = outer_r);
        translate([0, 0, bottom_t])
            cylinder(h = inner_h, r = inner_r);
    }
}

module handle_ring() {
    // トーラス（リング）をYZ平面に配置し、X方向へ飛び出す取手にする
    translate([handle_center_offset, 0, handle_z])
        rotate([90, 0, 0])
            rotate_extrude(angle = 360)
                translate([20, 0, 0])
                    circle(r = handle_tube_r);
}

union() {
    mug_body();
    handle_ring();
}