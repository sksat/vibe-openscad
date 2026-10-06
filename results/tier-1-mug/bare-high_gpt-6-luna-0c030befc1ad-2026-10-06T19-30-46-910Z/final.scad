$fn = 128;

cup_outer_diameter = 80;
cup_height = 100;
wall_thickness = 4;
bottom_thickness = 6;

handle_radius = 12;
handle_tube_radius = 3;
handle_center_x = 53;

module torus(major_radius, tube_radius) {
    rotate([90, 0, 0])
        rotate_extrude(convexity = 10)
            translate([major_radius, 0, 0])
                circle(r = tube_radius, $fn = 32);
}

union() {
    difference() {
        cylinder(
            h = cup_height,
            d = cup_outer_diameter
        );

        translate([0, 0, bottom_thickness])
            cylinder(
                h = cup_height - bottom_thickness + 1,
                d = cup_outer_diameter - 2 * wall_thickness
            );
    }

    translate([handle_center_x, 0, cup_height / 2])
        torus(handle_radius, handle_tube_radius);
}