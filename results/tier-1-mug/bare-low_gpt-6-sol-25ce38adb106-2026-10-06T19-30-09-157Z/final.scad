$fn = 96;

outer_radius = 40;
wall_thickness = 4;
bottom_thickness = 6;
cup_height = 100;

handle_radius = 12;
handle_thickness = 4;
handle_center_x = 53;
handle_center_z = cup_height / 2;

union() {
    difference() {
        cylinder(h = cup_height, r = outer_radius);

        translate([0, 0, bottom_thickness])
            cylinder(
                h = cup_height - bottom_thickness + 1,
                r = outer_radius - wall_thickness
            );
    }

    translate([handle_center_x, 0, handle_center_z])
        rotate([90, 0, 0])
            rotate_extrude()
                translate([handle_radius, 0])
                    circle(r = handle_thickness);
}