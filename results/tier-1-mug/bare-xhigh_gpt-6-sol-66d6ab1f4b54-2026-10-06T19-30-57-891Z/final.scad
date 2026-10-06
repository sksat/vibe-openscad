$fn = 96;

cup_outer_radius = 40;
cup_height = 100;
wall_thickness = 4;
bottom_thickness = 6;

handle_outer_radius = 12;
handle_inner_radius = 9;
handle_depth = 8;
handle_center_x = cup_outer_radius + 9;

union() {
    // 上部が開いたカップ本体
    difference() {
        cylinder(h = cup_height, r = cup_outer_radius);

        translate([0, 0, bottom_thickness])
            cylinder(
                h = cup_height - bottom_thickness + 0.1,
                r = cup_outer_radius - wall_thickness
            );
    }

    // カップの中ほどに付くリング状の取手
    translate([handle_center_x, 0, cup_height / 2])
        rotate([90, 0, 0])
            linear_extrude(height = handle_depth, center = true)
                difference() {
                    circle(r = handle_outer_radius);
                    circle(r = handle_inner_radius);
                }
}