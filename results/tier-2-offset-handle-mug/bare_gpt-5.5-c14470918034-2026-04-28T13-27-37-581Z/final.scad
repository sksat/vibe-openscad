$fn = 160;

eps = 0.05;

// Mug body
outer_d = 80;
inner_d = 70;
mug_h = 90;
bottom_t = 6;
outer_r = outer_d / 2;

// Handle
handle_open_w = 25;
handle_open_h = 30;
handle_wall = 8;
handle_depth = 18;
handle_embed = 2;
handle_z = mug_h / 2;

handle_x = outer_r - handle_embed + handle_wall;

function d_points(w, h, n = 64) =
    concat(
        [[0, -h / 2], [0, h / 2]],
        [for (i = [1 : n - 1])
            [
                w * cos(90 - 180 * i / n),
                (h / 2) * sin(90 - 180 * i / n)
            ]
        ]
    );

module mug_body() {
    difference() {
        cylinder(d = outer_d, h = mug_h);
        translate([0, 0, bottom_t])
            cylinder(d = inner_d, h = mug_h - bottom_t + eps);
    }
}

module handle_2d() {
    difference() {
        offset(r = handle_wall)
            polygon(points = d_points(handle_open_w, handle_open_h));
        polygon(points = d_points(handle_open_w, handle_open_h));
    }
}

module handle() {
    translate([handle_x, 0, handle_z])
        rotate([90, 0, 0])
            linear_extrude(height = handle_depth, center = true, convexity = 10)
                handle_2d();
}

union() {
    mug_body();
    handle();
}