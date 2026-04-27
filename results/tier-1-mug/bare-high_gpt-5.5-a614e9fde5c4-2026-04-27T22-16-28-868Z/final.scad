$fn = 128;

outer_d = 80;
cup_h = 100;
wall = 4;
bottom_t = 6;

outer_r = outer_d / 2;
inner_r = outer_r - wall;

handle_hole_r = 12;
handle_tube_r = 6;
handle_major_r = handle_hole_r + handle_tube_r;
handle_vertical_scale = 1.6;
handle_center_x = inner_r + handle_major_r + handle_tube_r;

module torus(major_r, tube_r) {
    rotate_extrude(convexity = 10, $fn = 160)
        translate([major_r, 0])
            circle(r = tube_r, $fn = 48);
}

module handle_ring() {
    translate([handle_center_x, 0, cup_h / 2])
        rotate([90, 0, 0])
            scale([1, handle_vertical_scale, 1])
                torus(handle_major_r, handle_tube_r);
}

difference() {
    union() {
        cylinder(h = cup_h, r = outer_r, $fn = 160);
        handle_ring();
    }

    translate([0, 0, bottom_t])
        cylinder(h = cup_h - bottom_t + 2, r = inner_r, $fn = 160);
}