$fn = 96;

// マグ本体寸法
outer_diameter = 80;
inner_diameter = 70;
mug_height     = 90;
bottom_thickness = 6;

// 取手寸法
handle_thickness_y = 12;
handle_center_z    = mug_height / 2;

// D字取手の2D形状を、XZ平面上に作成してY方向へ押し出す
module d_handle() {
    outer_cx = 50;
    outer_cz = handle_center_z;
    outer_r  = 21;

    inner_cx = 52;
    inner_cz = handle_center_z;
    inner_r  = 15;   // 内側高さ 30mm

    outer_left_x = 36;  // 本体外周(半径40)へ4mm重なる
    inner_left_x = 42;  // 内側空間の開始位置
    arc_steps = 48;

    outer_points = concat(
        [
            [outer_left_x, outer_cz - outer_r],
            [outer_cx,     outer_cz - outer_r]
        ],
        [
            for (i = [0 : arc_steps])
                [
                    outer_cx + outer_r * cos(-90 + 180 * i / arc_steps),
                    outer_cz + outer_r * sin(-90 + 180 * i / arc_steps)
                ]
        ],
        [
            [outer_left_x, outer_cz + outer_r]
        ]
    );

    inner_points = concat(
        [
            [inner_left_x, inner_cz - inner_r],
            [inner_cx,     inner_cz - inner_r]
        ],
        [
            for (i = [0 : arc_steps])
                [
                    inner_cx + inner_r * cos(-90 + 180 * i / arc_steps),
                    inner_cz + inner_r * sin(-90 + 180 * i / arc_steps)
                ]
        ],
        [
            [inner_left_x, inner_cz + inner_r]
        ]
    );

    rotate([90, 0, 0])
        linear_extrude(height = handle_thickness_y, center = true)
            difference() {
                polygon(points = outer_points);
                polygon(points = inner_points);
            }
}

union() {
    // 中空の円筒形マグ本体
    difference() {
        cylinder(d = outer_diameter, h = mug_height);

        translate([0, 0, bottom_thickness])
            cylinder(
                d = inner_diameter,
                h = mug_height - bottom_thickness + 1
            );
    }

    // +X方向にのみ配置した取手
    d_handle();
}