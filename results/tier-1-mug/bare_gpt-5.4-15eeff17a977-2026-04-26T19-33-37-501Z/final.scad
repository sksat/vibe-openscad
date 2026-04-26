$fn = 96;

// Main cup dimensions
outer_d = 80;
outer_r = outer_d / 2;
height = 100;
wall = 4;
bottom_thickness = 6;

// Handle dimensions
handle_tube_r = 12;          // radius of the ring tube
handle_major_r = 22;         // distance from torus center to tube center
handle_center_z = height / 2;
handle_center_x = outer_r + handle_major_r - 2;  // slightly intersect cup wall

module cup_body() {
    difference() {
        cylinder(h = height, r = outer_r);
        translate([0, 0, bottom_thickness])
            cylinder(h = height - bottom_thickness, r = outer_r - wall);
    }
}

module handle_ring() {
    translate([handle_center_x, 0, handle_center_z])
        rotate([90, 0, 0])
            rotate_extrude(angle = 360)
                translate([handle_major_r, 0, 0])
                    circle(r = handle_tube_r);
}

union() {
    cup_body();
    handle_ring();
}