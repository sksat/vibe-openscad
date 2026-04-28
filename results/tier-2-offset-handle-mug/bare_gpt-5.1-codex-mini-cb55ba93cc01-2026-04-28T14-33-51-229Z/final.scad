$fn = 120;

outer_radius = 40;
inner_radius = 35;
mug_height = 90;
bottom_thickness = 6;

handle_radius = 32;
handle_length = 12;
handle_inner_width = 25;
handle_inner_height = 30;
handle_margin = 2;

module mug_body() {
    difference() {
        // 外側
        cylinder(r = outer_radius, h = mug_height);
        // 内側（底面厚み分だけ高く）
        translate([0, 0, bottom_thickness])
            cylinder(r = inner_radius, h = mug_height - bottom_thickness);
    }
}

module handle_outer() {
    linear_extrude(height = handle_length, center = true)
        intersection() {
            circle(r = handle_radius);
            translate([0, -handle_radius])
                square([handle_radius, 2 * handle_radius]);
        }
}

module handle_body() {
    translate([outer_radius + handle_length / 2, 0, mug_height / 2])
        multmatrix([
            [0, 0, 1, 0],
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 0, 1]
        ])
            handle_outer();
}

module handle_cutout() {
    translate([
        outer_radius - handle_margin,
        0,
        mug_height / 2 - handle_inner_height / 2
    ])
        cube([handle_length + handle_margin * 2, handle_inner_width, handle_inner_height]);
}

module mug_handle() {
    difference() {
        handle_body();
        handle_cutout();
    }
}

union() {
    mug_body();
    mug_handle();
}