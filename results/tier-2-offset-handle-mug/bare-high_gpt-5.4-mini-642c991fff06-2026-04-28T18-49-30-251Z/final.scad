$fn = 96;

mug_h = 90;
body_od = 80;
body_id = 70;
base_th = 6;

handle_open_h = 30;
handle_open_w = 25;
handle_wall   = 5;

handle_outer_h = handle_open_h + 2 * handle_wall;
handle_outer_w = handle_open_w + 2 * handle_wall;

handle_depth = 18;
handle_x = body_od / 2 - 2;
handle_z = mug_h / 2;

module dshape(w, h) {
    r = h / 2;
    union() {
        translate([0, -r]) square([w - r, h], center = false);
        translate([w - r, 0]) circle(r = r);
    }
}

module body() {
    difference() {
        cylinder(h = mug_h, d = body_od);
        translate([0, 0, base_th])
            cylinder(h = mug_h - base_th + 2, d = body_id);
    }
}

module handle() {
    rotate([90, 0, 0])
        linear_extrude(height = handle_depth, center = true, convexity = 10)
            difference() {
                translate([handle_x, handle_z])
                    dshape(handle_outer_w, handle_outer_h);
                translate([handle_x + handle_wall, handle_z])
                    dshape(handle_open_w, handle_open_h);
            }
}

union() {
    body();
    handle();
}