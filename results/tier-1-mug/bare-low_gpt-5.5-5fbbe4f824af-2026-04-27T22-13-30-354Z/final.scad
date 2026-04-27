$fn = 128;

outer_diameter = 80;
outer_radius = outer_diameter / 2;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;
inner_radius = outer_radius - wall_thickness;

handle_major_radius = 18;
handle_tube_radius = 6;
handle_center_x = outer_radius + handle_major_radius - 4;
handle_center_z = height / 2;

module torus(major_radius, tube_radius) {
    rotate_extrude(convexity = 10)
        translate([major_radius, 0, 0])
            circle(r = tube_radius);
}

difference() {
    union() {
        cylinder(h = height, r = outer_radius);

        translate([handle_center_x, 0, handle_center_z])
            rotate([90, 0, 0])
                torus(handle_major_radius, handle_tube_radius);
    }

    translate([0, 0, bottom_thickness])
        cylinder(h = height + 2, r = inner_radius);
}