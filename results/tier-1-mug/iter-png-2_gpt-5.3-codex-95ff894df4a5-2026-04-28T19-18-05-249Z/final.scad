$fn = 128;

// Cup dimensions
outer_d = 80;
outer_r = outer_d / 2;
height  = 100;
wall_t  = 4;
bottom_t = 6;

inner_r = outer_r - wall_t;

// Handle dimensions (ring-shaped)
handle_tube_r = 12;      // specified: 半径12mm
handle_major_r = 22;     // ring radius to ensure finger-pass hole
handle_z = height / 2;   // centered in height

// Place handle so it intersects cup side and protrudes enough outward
// Inner-most x of handle = handle_center_x - (handle_major_r + handle_tube_r)
// Set this slightly inside outer wall for robust union.
handle_center_x = outer_r + (handle_major_r + handle_tube_r) - 2;

module mug_body() {
    difference() {
        cylinder(h = height, r = outer_r);
        // Hollow interior, leaving bottom thickness = 6mm
        translate([0, 0, bottom_t])
            cylinder(h = height - bottom_t + 0.2, r = inner_r);
    }
}

module handle_ring() {
    translate([handle_center_x, 0, handle_z])
        rotate([90, 0, 0])   // put torus axis along Y so it protrudes in +X
            rotate_extrude(angle = 360)
                translate([handle_major_r, 0, 0])
                    circle(r = handle_tube_r);
}

union() {
    mug_body();
    handle_ring();
}