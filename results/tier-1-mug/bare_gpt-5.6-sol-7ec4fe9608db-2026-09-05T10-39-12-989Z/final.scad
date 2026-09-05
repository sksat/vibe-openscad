$fn = 128;

outer_diameter = 80;
cup_height = 100;
wall_thickness = 4;
bottom_thickness = 6;

outer_radius = outer_diameter / 2;
inner_radius = outer_radius - wall_thickness;

handle_radius = 12;
handle_thickness = 4;
handle_center_x = outer_radius + handle_radius - handle_thickness;
handle_center_z = cup_height / 2;

union() {
    difference() {
        cylinder(h = cup_height, r = outer_radius);

        translate([0, 0, bottom_thickness])
            cylinder(
                h = cup_height - bottom_thickness + 1,
                r = inner_radius
            );
    }

    translate([handle_center_x, 0, handle_center_z])
        rotate([90, 0, 0])
            rotate_extrude()
                translate([handle_radius, 0])
                    circle(r = handle_thickness);
}