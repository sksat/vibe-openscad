$fn = 128;

module d_profile(width, height) {
    R = height / 2;
    rect_w = max(width - R, 0.01);
    pts = concat(
        [[0, -R], [rect_w, -R]],
        [for (a = [-90:5:90]) [rect_w + R * cos(a), R * sin(a)]],
        [[rect_w, R], [0, R], [0, -R]]
    );
    polygon(points = pts);
}

module mug_body() {
    difference() {
        cylinder(h = 90, r = 40);
        translate([0, 0, 6]) cylinder(h = 84, r = 35);
    }
}

module handle() {
    inner_w = 25;
    inner_h = 30;
    wall = 5;
    depth = 20;
    translate([38.5, 0, 45])
        rotate([90, 0, 0])
            linear_extrude(height = depth, center = true, convexity = 10)
                difference() {
                    offset(delta = wall) d_profile(inner_w, inner_h);
                    d_profile(inner_w, inner_h);
                }
}

union() {
    mug_body();
    handle();
}