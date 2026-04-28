$fn = 128;

outer_diameter = 80;
inner_diameter = 70;
mug_height = 90;
bottom_thickness = 6;

outer_radius = outer_diameter / 2;
inner_radius = inner_diameter / 2;

handle_opening_height = 30;
handle_opening_width = 25;
handle_wall = 7;
handle_depth = 16;
handle_center_z = mug_height / 2;

handle_opening_left_x = outer_radius + 5;

eps = 0.2;

module mug_body() {
    difference() {
        cylinder(h = mug_height, r = outer_radius);

        translate([0, 0, bottom_thickness])
            cylinder(h = mug_height - bottom_thickness + eps, r = inner_radius);
    }
}

module d_shape_2d(x0, z0, h, w, segments = 96) {
    r = h / 2;

    polygon(
        points = concat(
            [
                [x0, z0 - r]
            ],
            [
                for (i = [0 : segments])
                    let (a = -90 + 180 * i / segments)
                        [x0 + w * cos(a), z0 + r * sin(a)]
            ],
            [
                [x0, z0 + r]
            ]
        )
    );
}

module handle_profile() {
    difference() {
        offset(r = handle_wall)
            d_shape_2d(
                handle_opening_left_x,
                handle_center_z,
                handle_opening_height,
                handle_opening_width
            );

        d_shape_2d(
            handle_opening_left_x,
            handle_center_z,
            handle_opening_height,
            handle_opening_width
        );
    }
}

module handle() {
    rotate([90, 0, 0])
        linear_extrude(height = handle_depth, center = true, convexity = 10)
            handle_profile();
}

render(convexity = 10)
union() {
    mug_body();
    handle();
}