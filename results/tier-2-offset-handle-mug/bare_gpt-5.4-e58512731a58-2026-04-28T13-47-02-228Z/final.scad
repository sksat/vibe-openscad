$fn = 128;

// Mug dimensions
outer_d = 80;
inner_d = 70;
mug_h   = 90;
bottom_t = 6;

// Handle opening dimensions
handle_open_w = 25;   // radial width of finger opening
handle_open_h = 30;   // vertical height of finger opening

// Handle thickness around opening
handle_wall = 5;

// Derived
outer_r = outer_d / 2;
inner_r = inner_d / 2;

// Handle placement and size
handle_center_z = mug_h / 2;
handle_outer_h = handle_open_h + 2 * handle_wall;
handle_r = handle_outer_h / 2;                  // radius for rounded top/bottom in YZ profile
handle_straight_h = handle_open_h;              // straight section height in YZ profile

// Radial extents in X
handle_inner_x = outer_r - 1.0;                 // slight overlap into mug for manifold union
handle_outer_x = outer_r + handle_open_w + 2 * handle_wall;

// 2D D-shape in XZ plane, then extruded along Y
module d_shape_2d(x0, x1, zc, open_h) {
    r = open_h / 2;
    union() {
        translate([x0, zc - r]) square([x1 - x0 - r, open_h], center = false);
        translate([x1 - r, zc]) circle(r = r);
    }
}

module mug_body() {
    difference() {
        cylinder(h = mug_h, r = outer_r);
        translate([0, 0, bottom_t])
            cylinder(h = mug_h - bottom_t + 0.01, r = inner_r);
    }
}

module handle() {
    difference() {
        // Outer D-shape
        translate([0, -handle_r, 0])
            rotate([-90, 0, 0])
                linear_extrude(height = 2 * handle_r)
                    d_shape_2d(handle_inner_x, handle_outer_x, handle_center_z, handle_outer_h);

        // Inner opening D-shape
        translate([0, -handle_open_h/2, 0])
            rotate([-90, 0, 0])
                linear_extrude(height = handle_open_h)
                    d_shape_2d(outer_r + handle_wall, outer_r + handle_wall + handle_open_w, handle_center_z, handle_open_h);
    }
}

union() {
    mug_body();
    handle();
}