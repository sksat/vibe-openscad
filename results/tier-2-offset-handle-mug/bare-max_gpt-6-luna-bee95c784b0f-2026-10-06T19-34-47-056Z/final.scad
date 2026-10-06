outer_d = 80;
inner_d = 70;
mug_height = 90;
bottom_thickness = 6;

opening_width = 25;
opening_height = 30;
handle_band = 5;
handle_depth = 10;

opening_radius = opening_height / 2;
opening_arc_center_x = opening_width - opening_radius;

$fn = 128;

module mug_body() {
    difference() {
        cylinder(d = outer_d, h = mug_height);

        translate([0, 0, bottom_thickness])
            cylinder(
                d = inner_d,
                h = mug_height - bottom_thickness + 1
            );
    }
}

module d_profile(radius, left_x, center_x) {
    union() {
        translate([left_x, -radius])
            square([center_x - left_x, 2 * radius]);

        intersection() {
            translate([center_x, 0])
                circle(r = radius);

            translate([center_x, -radius])
                square([radius, 2 * radius]);
        }
    }
}

module handle() {
    translate([outer_d / 2, 0, mug_height / 2])
        rotate([90, 0, 0])
            linear_extrude(height = handle_depth, center = true)
                difference() {
                    d_profile(
                        opening_radius + handle_band,
                        -handle_band,
                        opening_arc_center_x
                    );

                    d_profile(
                        opening_radius,
                        0,
                        opening_arc_center_x
                    );
                }
}

union() {
    mug_body();
    handle();
}