$fn = 192;

outer_diameter = 80;
inner_diameter = 70;
mug_height     = 90;
bottom_thickness = 6;

handle_hole_height = 30;
handle_hole_width  = 25;
handle_depth       = 10; // Y方向の厚み
handle_rim         = 5;
attachment_overlap = 3; // 本体への食い込み量

handle_base_x = outer_diameter / 2 - attachment_overlap;
handle_center_z = mug_height / 2;

// 外周を真の半円にし、開口の前後に5mmの肉を確保
handle_outer_radius = handle_hole_width + 2 * handle_rim;

epsilon = 0.02;

// 2D：+X側の半円。本体側の境界は直線。
module right_semicircle(r) {
    intersection() {
        circle(r = r);
        translate([0, -r])
            square([r, 2 * r]);
    }
}

// 2D：外周が半円、内側開口が幅25mm×高さ30mmのD字形
module handle_profile() {
    difference() {
        right_semicircle(handle_outer_radius);

        translate([handle_rim, 0])
            scale([handle_hole_width, handle_hole_height / 2])
                right_semicircle(1);
    }
}

// 取手をXZ平面に配置し、Y方向へ厚みを付ける
module handle() {
    translate([handle_base_x, 0, handle_center_z])
        rotate([90, 0, 0])
            linear_extrude(height = handle_depth, center = true)
                handle_profile();
}

difference() {
    // 取手の直線側が本体に3mm入り込み、体積を持って接続
    union() {
        cylinder(d = outer_diameter, h = mug_height);
        handle();
    }

    // 上面を開放し、底面に6mmを残す
    translate([0, 0, bottom_thickness])
        cylinder(
            d = inner_diameter,
            h = mug_height - bottom_thickness + epsilon
        );
}