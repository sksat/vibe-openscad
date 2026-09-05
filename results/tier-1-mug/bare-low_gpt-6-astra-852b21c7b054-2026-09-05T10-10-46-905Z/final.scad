$fn = 128;

// 寸法（mm）
outer_diameter = 80;
cup_height = 100;
wall_thickness = 4;
bottom_thickness = 6;

handle_radius = 12;       // リング中心線の半径
handle_tube_radius = 4;   // 取手の断面半径
handle_center_x = outer_diameter / 2 + 10;
handle_center_z = cup_height / 2;

epsilon = 0.1;

difference() {
    union() {
        // カップ本体
        cylinder(d = outer_diameter, h = cup_height);

        // 側面に接続するリング状の取手（XZ平面）
        translate([handle_center_x, 0, handle_center_z])
            rotate([90, 0, 0])
                rotate_extrude()
                    translate([handle_radius, 0, 0])
                        circle(r = handle_tube_radius);
    }

    // 上面を開口し、底厚6mm・側壁厚4mmを確保
    translate([0, 0, bottom_thickness])
        cylinder(
            d = outer_diameter - 2 * wall_thickness,
            h = cup_height - bottom_thickness + epsilon
        );
}