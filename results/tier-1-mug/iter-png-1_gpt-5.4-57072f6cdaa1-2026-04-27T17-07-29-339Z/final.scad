$fn = 128;

// Cup dimensions
outer_d = 80;
outer_r = outer_d / 2;
height = 100;
wall = 4;
bottom_thickness = 6;

// Handle dimensions
handle_tube_r = 12;          // radius of the ring section
handle_major_r = 18;         // ring center to tube center
handle_center_z = height / 2;
handle_center_x = outer_r + handle_major_r - 4;  // intersect outer wall by tube radius

module cup() {
    difference() {
        cylinder(h = height, r = outer_r);
        translate([0, 0, bottom_thickness])
            cylinder(h = height - bottom_thickness + 0.1, r = outer_r - wall);
    }
}

module ring_handle() {
    translate([handle_center_x, 0, handle_center_z])
        rotate([0, 90, 0])
            rotate_extrude(convexity = 10)
                translate([handle_major_r, 0, 0])
                    circle(r = handle_tube_r);
}

union() {
    cup();
    ring_handle();
}