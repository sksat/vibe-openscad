$fn = 128;

outer_d = 80;
height = 100;
wall = 4;
bottom = 6;

module mug_body() {
    difference() {
        cylinder(d = outer_d, h = height);
        translate([0, 0, bottom])
            cylinder(d = outer_d - 2 * wall, h = height - bottom + 0.1);
    }
}

module ring_handle() {
    translate([outer_d/2 + 12 - 4, 0, height/2])
        rotate([90, 0, 0])
            rotate_extrude(convexity = 10)
                translate([12, 0, 0])
                    circle(r = 4);
}

union() {
    mug_body();
    ring_handle();
}