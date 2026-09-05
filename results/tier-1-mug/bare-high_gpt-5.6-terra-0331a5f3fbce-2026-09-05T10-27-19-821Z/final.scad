$fn = 128;

// カップ寸法
outer_diameter = 80;
outer_radius   = outer_diameter / 2;
height         = 100;
wall_thickness = 4;
bottom_thickness = 6;

// 取手寸法
handle_outer_radius = 12;
handle_inner_radius = 8;
handle_depth        = 8;
handle_center_x     = outer_radius + handle_outer_radius - 2;
handle_center_z     = height / 2;

union() {
    // カップ本体
    difference() {
        cylinder(r = outer_radius, h = height);

        // 内側のくり抜き
        translate([0, 0, bottom_thickness])
            cylinder(
                r = outer_radius - wall_thickness,
                h = height - bottom_thickness + 1
            );
    }

    // リング状の取手
    translate([handle_center_x, 0, handle_center_z])
        rotate([90, 0, 0])
            difference() {
                cylinder(
                    r = handle_outer_radius,
                    h = handle_depth,
                    center = true
                );

                cylinder(
                    r = handle_inner_radius,
                    h = handle_depth + 2,
                    center = true
                );
            }
}