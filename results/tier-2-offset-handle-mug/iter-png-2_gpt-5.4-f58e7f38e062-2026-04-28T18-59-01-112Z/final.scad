$fn = 128;

// Mug dimensions
outer_d   = 80;
inner_d   = 70;
mug_h     = 90;
bottom_t  = 6;

// Handle inner opening dimensions
handle_open_w = 25;   // radial width
handle_open_h = 30;   // vertical height

// Handle thickness
handle_t = 5;

// Derived radii
outer_r = outer_d / 2;
inner_r = inner_d / 2;

// Handle outer dimensions
handle_outer_w = handle_open_w + handle_t;
handle_outer_h = handle_open_h + 2 * handle_t;

// Placement
handle_center_z = mug_h / 2;
attach_overlap = 1.0;

// 2D D-shape on XY plane:
// flat side at x = x_left, rounded side toward +X
module d_shape_2d(x_left, y_center, total_w, total_h) {
    r = total_h / 2;
    rect_w = total_w - r;
    union() {
        translate([x_left, y_center - r])
            square([rect_w, total_h], center = false);
        translate([x_left + rect_w, y_center])
            circle(r = r);
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
    rotate([90, 0, 0]) {
        difference() {
            linear_extrude(height = handle_t, center = true)
                d_shape_2d(outer_r - attach_overlap, handle_center_z, handle_outer_w + attach_overlap, handle_outer_h);

            linear_extrude(height = handle_t + 2, center = true)
                d_shape_2d(outer_r + handle_t, handle_center_z, handle_open_w, handle_open_h);
        }
    }
}

union() {
    mug_body();
    handle();
}