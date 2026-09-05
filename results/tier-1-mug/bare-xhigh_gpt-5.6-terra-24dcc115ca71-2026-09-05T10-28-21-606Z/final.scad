$fn = 96;

cup_outer_radius = 40;
cup_inner_radius = 36;
cup_height       = 100;
bottom_thickness = 6;

handle_inner_radius = 12;
handle_grip_radius  = 4;
handle_major_radius = handle_inner_radius + handle_grip_radius;
handle_center_x     = cup_outer_radius + handle_major_radius + handle_grip_radius - 2;
handle_center_z     = cup_height / 2;

module cup_body() {
    difference() {
        cylinder(r = cup_outer_radius, h = cup_height);

        translate([0, 0, bottom_thickness])
            cylinder(
                r = cup_inner_radius,
                h = cup_height - bottom_thickness + 1
            );
    }
}

module handle() {
    translate([handle_center_x, 0, handle_center_z])
        rotate([90, 0, 0])
            rotate_extrude()
                translate([handle_major_radius, 0, 0])
                    circle(r = handle_grip_radius, $fn = 32);
}

union() {
    cup_body();
    handle();
}