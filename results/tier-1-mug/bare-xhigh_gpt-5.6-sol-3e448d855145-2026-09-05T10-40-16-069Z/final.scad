$fn = 128;

outer_radius = 40;
wall_thickness = 4;
inner_radius = outer_radius - wall_thickness;
cup_height = 100;
bottom_thickness = 6;

handle_outer_radius = 12;
handle_inner_radius = 8;
handle_thickness = 8;
handle_center_x = outer_radius + handle_outer_radius - 2;
handle_center_z = cup_height / 2;

union() {
    difference() {
        cylinder(r = outer_radius, h = cup_height);

        translate([0, 0, bottom_thickness])
            cylinder(
                r = inner_radius,
                h = cup_height - bottom_thickness + 1
            );
    }

    translate([handle_center_x, 0, handle_center_z])
        rotate([90, 0, 0])
            difference() {
                cylinder(
                    r = handle_outer_radius,
                    h = handle_thickness,
                    center = true
                );

                cylinder(
                    r = handle_inner_radius,
                    h = handle_thickness + 2,
                    center = true
                );
            }
}