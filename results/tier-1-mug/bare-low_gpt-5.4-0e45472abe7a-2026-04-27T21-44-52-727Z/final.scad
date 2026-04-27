$fn = 128;

outer_d = 80;
outer_r = outer_d / 2;
height = 100;
wall = 4;
bottom = 6;
inner_r = outer_r - wall;

handle_major_r = 12;
handle_minor_r = 4;
handle_z = height / 2;
handle_x = outer_r + handle_major_r - 2;

module mug_body() {
    difference() {
        cylinder(h = height, r = outer_r);
        translate([0, 0, bottom])
            cylinder(h = height - bottom, r = inner_r);
    }
}

module handle() {
    translate([handle_x, 0, handle_z])
        rotate([90, 0, 0])
            rotate_extrude(convexity = 10)
                translate([handle_major_r, 0, 0])
                    circle(r = handle_minor_r);
}

union() {
    mug_body();
    handle();
}