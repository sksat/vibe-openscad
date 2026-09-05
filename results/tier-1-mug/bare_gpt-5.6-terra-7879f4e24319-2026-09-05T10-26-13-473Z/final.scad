$fn = 128;

// マグカップ寸法
outer_radius = 40;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;

// 取手寸法
handle_center_x = 55;
handle_center_z = height / 2;
handle_outer_radius = 18;
handle_inner_radius = 12;
handle_depth = 10;

// カップ本体
difference() {
    cylinder(h = height, r = outer_radius);

    translate([0, 0, bottom_thickness])
        cylinder(
            h = height - bottom_thickness + 1,
            r = outer_radius - wall_thickness
        );
}

// リング状の取手
translate([handle_center_x, 0, handle_center_z])
rotate([90, 0, 0])
difference() {
    cylinder(h = handle_depth, r = handle_outer_radius, center = true);
    cylinder(h = handle_depth + 2, r = handle_inner_radius, center = true);
}