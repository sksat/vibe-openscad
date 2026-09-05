$fn = 128;

mug_outer_radius = 40;
mug_inner_radius = 35;
mug_height       = 90;
bottom_thickness = 6;

handle_opening_width  = 25;
handle_opening_height = 30;
handle_wall           = 7;
handle_depth          = 14;
handle_center_z       = mug_height / 2;

epsilon = 0.2;

module mug_body() {
    difference() {
        cylinder(r = mug_outer_radius, h = mug_height);

        translate([0, 0, bottom_thickness])
            cylinder(
                r = mug_inner_radius,
                h = mug_height - bottom_thickness + epsilon
            );
    }
}

module d_profile(x_left, arc_center_x, radius, segments = 96) {
    polygon(points = concat(
        [[x_left, -radius]],
        [
            for (i = [0 : segments])
                [
                    arc_center_x
                        + radius * cos(-90 + 180 * i / segments),
                    radius * sin(-90 + 180 * i / segments)
                ]
        ],
        [[x_left, radius]]
    ));
}

module mug_handle() {
    opening_radius = handle_opening_height / 2;
    opening_left_x = mug_outer_radius + 3;
    arc_center_x   = opening_left_x
                   + handle_opening_width
                   - opening_radius;

    outer_radius = opening_radius + handle_wall;
    outer_left_x = opening_left_x - handle_wall;

    translate([0, 0, handle_center_z])
        rotate([90, 0, 0])
            linear_extrude(
                height = handle_depth,
                center = true,
                convexity = 10
            )
                difference() {
                    d_profile(
                        outer_left_x,
                        arc_center_x,
                        outer_radius
                    );

                    d_profile(
                        opening_left_x,
                        arc_center_x,
                        opening_radius
                    );
                }
}

union() {
    mug_body();
    mug_handle();
}