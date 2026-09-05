$fn = 128;

outer_diameter = 80;
outer_radius = outer_diameter / 2;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;

inner_radius = outer_radius - wall_thickness;

handle_radius = 12;
handle_tube_radius = 4;
handle_center_x = outer_radius + handle_tube_radius + handle_radius - wall_thickness;
handle_center_z = height / 2;

module cup_body() {
    difference() {
        cylinder(
            h = height,
            r = outer_radius
        );

        translate([0, 0, bottom_thickness])
            cylinder(
                h = height - bottom_thickness + 1,
                r = inner_radius
            );
    }
}

module ring_handle() {
    translate([handle_center_x, 0, handle_center_z])
        rotate([90, 0, 0])
            rotate_extrude(convexity = 10)
                translate([handle_radius, 0, 0])
                    circle(r = handle_tube_radius);
}

union() {
    cup_body();
    ring_handle();
}