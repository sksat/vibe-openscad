$fn = 128;

mug_outer_d = 80;
mug_height = 100;
wall_thickness = 4;
bottom_thickness = 6;

handle_ring_outer = 12;
handle_ring_inner = 6;
handle_depth = 18;
handle_overlap = 2;
handle_offset = mug_outer_d/2 + handle_ring_outer - handle_overlap;

module mug_body() {
    difference() {
        cylinder(h = mug_height, r = mug_outer_d/2);
        translate([0, 0, bottom_thickness])
            cylinder(h = mug_height - bottom_thickness + 0.1, r = mug_outer_d/2 - wall_thickness);
    }
}

module ring_handle() {
    translate([handle_offset, 0, mug_height/2])
        rotate([-90, 0, 0])
            linear_extrude(height = handle_depth, center = true, convexity = 10)
                difference() {
                    circle(r = handle_ring_outer);
                    circle(r = handle_ring_inner);
                }
}

union() {
    mug_body();
    ring_handle();
}