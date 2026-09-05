$fn = 128;

outer_diameter = 80;
inner_diameter = 70;
mug_height = 90;
bottom_thickness = 6;

handle_center_z = mug_height / 2;
handle_outer_x = 36;
handle_outer_radius = 32;
handle_inner_x = 40;
handle_inner_width = 25;
handle_inner_height = 30;
handle_thickness = 14;
handle_segments = 128;

module mug_body() {
    difference() {
        cylinder(
            d = outer_diameter,
            h = mug_height
        );

        translate([0, 0, bottom_thickness])
            cylinder(
                d = inner_diameter,
                h = mug_height + 1
            );
    }
}

module handle_outer_profile() {
    polygon(points = [
        for (i = [0 : handle_segments])
            [
                handle_outer_x
                    + handle_outer_radius
                    * cos(90 - 180 * i / handle_segments),
                handle_center_z
                    + handle_outer_radius
                    * sin(90 - 180 * i / handle_segments)
            ]
    ]);
}

module handle_inner_profile() {
    polygon(points = [
        for (i = [0 : handle_segments])
            [
                handle_inner_x
                    + (handle_inner_width / 2)
                    * cos(90 - 180 * i / handle_segments),
                handle_center_z
                    + (handle_inner_height / 2)
                    * sin(90 - 180 * i / handle_segments)
            ]
    ]);
}

module handle() {
    rotate([90, 0, 0])
        linear_extrude(
            height = handle_thickness,
            center = true,
            convexity = 10
        )
            difference() {
                handle_outer_profile();
                handle_inner_profile();
            }
}

union() {
    mug_body();
    handle();
}