$fn = 128;

cup_outer_diameter = 80;
cup_height = 100;
wall_thickness = 4;
bottom_thickness = 6;

handle_outer_radius = 12;
handle_ring_thickness = 3;
handle_width = 6;
handle_overlap = 2;

epsilon = 0.1;
cup_outer_radius = cup_outer_diameter / 2;
cup_inner_radius = cup_outer_radius - wall_thickness;

difference() {
    union() {
        cylinder(h = cup_height, r = cup_outer_radius);

        translate([
            cup_outer_radius + handle_outer_radius - handle_overlap,
            0,
            cup_height / 2
        ])
            rotate([90, 0, 0])
                difference() {
                    cylinder(
                        h = handle_width,
                        r = handle_outer_radius,
                        center = true
                    );
                    cylinder(
                        h = handle_width + 2 * epsilon,
                        r = handle_outer_radius - handle_ring_thickness,
                        center = true
                    );
                }
    }

    translate([0, 0, bottom_thickness])
        cylinder(
            h = cup_height - bottom_thickness + epsilon,
            r = cup_inner_radius
        );
}