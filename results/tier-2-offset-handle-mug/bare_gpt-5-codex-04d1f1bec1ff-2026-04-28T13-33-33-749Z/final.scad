$fa = 6;
$fs = 0.5;

outer_diameter = 80;
inner_diameter = 70;
mug_height = 90;
bottom_thickness = 6;

outer_radius = outer_diameter / 2;
inner_radius = inner_diameter / 2;

handle_inner_height = 30;
handle_inner_width = 25;
handle_wall_thickness = 5;
handle_depth_y = 20;
handle_center_height = mug_height / 2;
handle_attach_x = inner_radius;

handle_inner_radius = handle_inner_height / 2;
handle_outer_radius = handle_inner_radius + handle_wall_thickness;
handle_inner_flat = handle_inner_width - handle_inner_radius;
handle_outer_flat = handle_inner_flat + handle_wall_thickness;

module d_profile(flat_depth, radius, steps=72) {
    polygon(points = concat(
        [[0, -radius], [0, radius]],
        [for (i = [0:steps]) [
            flat_depth + radius * cos(90 - 180 * i / steps),
            radius * sin(90 - 180 * i / steps)
        ]]
    ));
}

module mug_body() {
    difference() {
        cylinder(h = mug_height, r = outer_radius);
        translate([0, 0, bottom_thickness])
            cylinder(h = mug_height - bottom_thickness, r = inner_radius);
    }
}

module mug_handle() {
    translate([handle_attach_x, 0, handle_center_height])
        rotate([90, 0, 0])
            difference() {
                linear_extrude(height = handle_depth_y, center = true, convexity = 10)
                    d_profile(handle_outer_flat, handle_outer_radius);
                linear_extrude(height = handle_depth_y, center = true, convexity = 10)
                    d_profile(handle_inner_flat, handle_inner_radius);
            }
}

union() {
    mug_body();
    mug_handle();
}