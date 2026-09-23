$fn = 128;

outer_d = 80;
H = 100;
wall = 4;
bottom_t = 6;
inner_d = outer_d - 2 * wall;

handle_major = 12;
handle_minor = 3;
handle_x = outer_d / 2 + handle_major;

module torus(R, r) {
    rotate_extrude(angle = 360) {
        circle(d = 2 * r, center = [R, 0]);
    }
}

module cup() {
    difference() {
        cylinder(d = outer_d, h = H);
        translate([0, 0, bottom_t]) {
            cylinder(d = inner_d, h = H);
        }
    }
}

module handle() {
    translate([handle_x, 0, H / 2]) {
        rotate([90, 0, 0]) {
            torus(handle_major, handle_minor);
        }
    }
}

union() {
    cup();
    handle();
}