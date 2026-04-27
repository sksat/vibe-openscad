$fn = 128;

// Mug dimensions
outer_d = 80;
outer_r = outer_d / 2;
height = 100;
wall = 4;
bottom_thickness = 6;

// Handle dimensions
handle_tube_r = 12;          // tube radius of the ring handle
handle_outer_proj = 28;      // outward projection from mug outer surface to handle outermost edge
handle_center_z = height / 2;

// Place handle so it attaches to the mug outer wall and protrudes outward
handle_major_r = (handle_outer_proj - handle_tube_r) / 2 + handle_tube_r;
handle_center_x = outer_r + (handle_outer_proj - handle_tube_r) / 2;

module mug() {
    difference() {
        cylinder(h = height, r = outer_r);
        translate([0, 0, bottom_thickness])
            cylinder(h = height - bottom_thickness + 0.1, r = outer_r - wall);
    }
}

module handle() {
    translate([handle_center_x, 0, handle_center_z])
        rotate([0, 90, 0])
            rotate_extrude(convexity = 10)
                translate([handle_major_r, 0, 0])
                    circle(r = handle_tube_r);
}

union() {
    mug();
    handle();
}