$fn = 180;

outer_d = 80;
outer_r = outer_d / 2;
height = 100;
wall = 4;
bottom = 6;

handle_major_r = 12;
handle_tube_r = 4;
handle_center_x = outer_r + handle_major_r + 1;
handle_center_z = height / 2;

module cup_body() {
    difference() {
        cylinder(h = height, r = outer_r);
        translate([0, 0, bottom])
            cylinder(h = height - bottom + 0.2, r = outer_r - wall);
    }
}

module torus(R, r) {
    rotate_extrude(convexity = 10)
        translate([R, 0, 0])
            circle(r = r);
}

union() {
    cup_body();

    translate([handle_center_x, 0, handle_center_z])
        rotate([90, 0, 0])
            torus(handle_major_r, handle_tube_r);
}