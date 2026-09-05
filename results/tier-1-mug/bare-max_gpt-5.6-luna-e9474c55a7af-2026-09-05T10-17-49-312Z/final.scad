$fn = 128;

outer_diameter = 80;
cup_height = 100;
wall_thickness = 4;
bottom_thickness = 6;

outer_radius = outer_diameter / 2;
inner_radius = outer_radius - wall_thickness;

handle_radius = 12;
handle_tube_radius = 4;
handle_center_x = outer_radius + handle_radius;
handle_center_z = cup_height / 2;

module torus(major_radius, minor_radius) {
    rotate_extrude(convexity = 10)
        translate([major_radius, 0, 0])
            circle(r = minor_radius);
}

module cup() {
    difference() {
        cylinder(r = outer_radius, h = cup_height);

        translate([0, 0, bottom_thickness])
            cylinder(r = inner_radius, h = cup_height);
    }
}

union() {
    cup();

    translate([handle_center_x, 0, handle_center_z])
        rotate([90, 0, 0])
            torus(handle_radius, handle_tube_radius);
}