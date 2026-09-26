$fn = 128;

outer_d = 80;
H = 100;
wall = 4;
bottom_t = 6;
inner_d = outer_d - 2 * wall;

handle_r = 12;
handle_width = 8;
handle_depth = 12;
handle_cx = 52;

module cup() {
    difference() {
        cylinder(d = outer_d, h = H);
        translate([0, 0, bottom_t]) {
            cylinder(d = inner_d, h = H);
        }
    }
}

module handle() {
    translate([handle_cx, 0, H / 2]) {
        rotate([90, 0, 0]) {
            translate([0, 0, -handle_depth / 2]) {
                difference() {
                    cylinder(d = 2 * (handle_r + handle_width / 2), h = handle_depth);
                    cylinder(d = 2 * (handle_r - handle_width / 2), h = handle_depth);
                }
            }
        }
    }
}

union() {
    cup();
    handle();
}