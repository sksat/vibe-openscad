$fn = 128;

outer_d = 80;
height = 100;
wall = 4;
bottom = 6;

handle_R = 12;
handle_r = 3;

module torus(R, r) {
    rotate_extrude(convexity = 10)
        translate([R, 0, 0])
            circle(r = r, $fn = 64);
}

union() {
    difference() {
        cylinder(h = height, r = outer_d / 2);
        translate([0, 0, bottom])
            cylinder(h = height - bottom + 0.2, r = outer_d / 2 - wall);
    }

    translate([outer_d / 2 + handle_R, 0, height / 2])
        rotate([90, 0, 0])
            torus(handle_R, handle_r);
}