$fn = 160;

outer_diameter = 80;
cup_height = 100;
wall_thickness = 4;
bottom_thickness = 6;

handle_outer_radius = 12;
handle_tube_radius = 1.5;
handle_overlap = 2;

outer_radius = outer_diameter / 2;
inner_radius = outer_radius - wall_thickness;
handle_major_radius = handle_outer_radius - handle_tube_radius;
handle_center_x = outer_radius + handle_outer_radius - handle_overlap;

epsilon = 0.02;

difference() {
    union() {
        cylinder(r = outer_radius, h = cup_height);

        // 外半径12mm、指を通す穴の直径18mmのリング状取手
        translate([handle_center_x, 0, cup_height / 2])
            rotate([90, 0, 0])
                rotate_extrude(convexity = 10)
                    translate([handle_major_radius, 0, 0])
                        circle(r = handle_tube_radius);
    }

    // 底厚6mmを残し、上面まで内側をくり抜く
    translate([0, 0, bottom_thickness])
        cylinder(
            r = inner_radius,
            h = cup_height - bottom_thickness + epsilon
        );
}