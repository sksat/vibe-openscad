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
handle_attach_overlap = 2.5;

eps = 0.2;

module mug_body() {
    difference() {
        cylinder(h = mug_height, r = outer_radius);

        translate([0, 0, bottom_thickness])
            cylinder(h = mug_height - bottom_thickness + eps, r = inner_radius);
    }
}

module d_shape(x0, z0, h, w, segments = 72) {
    polygon(
        points = concat(
            [[x0, z0 - h / 2]],
            [
                for (i = [1 : segments - 1])
                    let (a = -90 + 180 * i / segments)
                        [x0 + w * cos(a), z0 + (h / 2) * sin(a)]
            ],
            [[x0, z0 + h / 2]]
        )
    );
}

module handle_profile() {
    difference() {
        offset(r = handle_wall)
            d_shape(
                handle_opening_left_x,
                handle_center_z,
                handle_opening_height,
                handle_opening_width
            );

        d_shape(
            handle_opening_left_x,
            handle_center_z,
            handle_opening_height,
            handle_opening_width
        );
    }
}

module handle() {
    union() {
        rotate([90, 0, 0])
            linear_extrude(height = handle_depth, center = true, convexity = 10)
                handle_profile();

        translate([
            outer_radius - handle_attach_overlap,
            -handle_depth / 2,
            handle_center_z - handle_opening_height / 2 - handle_wall
        ])
            cube([
                handle_opening_left_x - (outer_radius - handle_attach_overlap),
                handle_depth,
                handle_opening_height + 2 * handle_wall
            ]);
    }
}

render(convexity = 10)
union() {
    mug_body();
    handle();
}