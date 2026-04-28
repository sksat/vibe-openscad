$fn = 128;

mug_outer_d = 80;
mug_inner_d = 70;
mug_height  = 90;
bottom_th   = 6;

outer_r = mug_outer_d / 2;
inner_r = mug_inner_d / 2;

handle_inner_h = 30;
handle_inner_w = 25;
handle_th      = 8;
handle_depth   = 16;
handle_z       = mug_height / 2;
handle_attach_x = outer_r - 2;

handle_outer_h = handle_inner_h + handle_th * 2;
handle_outer_w = handle_inner_w + handle_th * 2;

function d_shape_points(w, h, n = 64) =
    let(r = h / 2, cx = w - r)
    concat(
        [[0, -r]],
        [for (i = [0:n])
            let(a = -90 + 180 * i / n)
            [cx + r * cos(a), r * sin(a)]
        ],
        [[0, r]]
    );

module d_shape_2d(w, h) {
    polygon(points = d_shape_points(w, h));
}

module mug_body() {
    difference() {
        cylinder(h = mug_height, r = outer_r);
        translate([0, 0, bottom_th])
            cylinder(h = mug_height, r = inner_r);
    }
}

module handle() {
    rotate([90, 0, 0])
        linear_extrude(height = handle_depth, center = true, convexity = 10)
            translate([handle_attach_x, handle_z])
                difference() {
                    d_shape_2d(handle_outer_w, handle_outer_h);
                    translate([handle_th, 0])
                        d_shape_2d(handle_inner_w, handle_inner_h);
                }
}

union() {
    mug_body();
    handle();
}