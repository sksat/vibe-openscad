$fn = 96;

cup_outer_radius = 40;
cup_height = 100;
wall_thickness = 4;
bottom_thickness = 6;

handle_outer_radius = 12;
handle_inner_radius = 8;
handle_thickness = 12;
handle_center_x = 50;
handle_center_z = cup_height / 2;

union() {
    difference() {
        cylinder(h = cup_height, r = cup_outer_radius);

        translate([0, 0, bottom_thickness])
            cylinder(
                h = cup_height - bottom_thickness + 1,
                r = cup_outer_radius - wall_thickness
            );
    }

    translate([handle_center_x, 0, handle_center_z])
        rotate([90, 0, 0])
            linear_extrude(height = handle_thickness, center = true)
                difference() {
                    circle(r = handle_outer_radius);
                    circle(r = handle_inner_radius);
                }
}