$fn = 128;

outer_d = 80;
inner_d = 70;
height = 90;
bottom_thickness = 6;

outer_r = outer_d / 2;
inner_r = inner_d / 2;

// Handle parameters
handle_depth = 16;          // Y方向の厚み
handle_wall = 8;
handle_center_z = height / 2;

inner_handle_h = 30;
inner_handle_w = 25;

inner_x0 = outer_r + 4;     // 取手内側の本体側直線位置
inner_rx = inner_handle_w;
inner_ry = inner_handle_h / 2;

outer_x0 = outer_r - 4;     // 本体外周へ確実に食い込ませて接続
outer_rx = inner_handle_w + handle_wall * 2;
outer_ry = inner_ry + handle_wall;

module d_shape_2d(x0, zc, rx, ry, steps = 64) {
    pts = concat(
        [[x0, zc - ry], [x0, zc + ry]],
        [for (i = [0 : steps])
            let(a = 90 - 180 * i / steps)
            [x0 + rx * cos(a), zc + ry * sin(a)]
        ]
    );
    polygon(points = pts);
}

module handle() {
    rotate([90, 0, 0])
        linear_extrude(height = handle_depth, center = true, convexity = 10)
            difference() {
                d_shape_2d(
                    outer_x0,
                    handle_center_z,
                    outer_rx,
                    outer_ry
                );
                d_shape_2d(
                    inner_x0,
                    handle_center_z,
                    inner_rx,
                    inner_ry
                );
            }
}

module mug_body_outer() {
    cylinder(h = height, r = outer_r);
}

module mug_inner_void() {
    translate([0, 0, bottom_thickness])
        cylinder(h = height + 2, r = inner_r);
}

difference() {
    union() {
        mug_body_outer();
        handle();
    }
    mug_inner_void();
}