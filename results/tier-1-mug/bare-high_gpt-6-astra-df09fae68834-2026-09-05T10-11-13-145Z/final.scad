$fn = 128;

outer_diameter = 80;
cup_height = 100;
wall_thickness = 4;
bottom_thickness = 6;

handle_radius = 12;
handle_tube_radius = wall_thickness / 2;

outer_radius = outer_diameter / 2;
inner_radius = outer_radius - wall_thickness;
handle_center_x = outer_radius + handle_radius - handle_tube_radius;

epsilon = 0.01;

difference() {
    union() {
        // カップ本体
        cylinder(h = cup_height, r = outer_radius);

        // 側面から外向きに張り出す、縦向きのリング状取手
        translate([handle_center_x, 0, cup_height / 2])
            rotate([90, 0, 0])
                rotate_extrude(convexity = 10)
                    translate([handle_radius, 0, 0])
                        circle(r = handle_tube_radius);
    }

    // 底厚6mmを残し、上面まで内側をくり抜く
    translate([0, 0, bottom_thickness])
        cylinder(
            h = cup_height - bottom_thickness + epsilon,
            r = inner_radius
        );
}