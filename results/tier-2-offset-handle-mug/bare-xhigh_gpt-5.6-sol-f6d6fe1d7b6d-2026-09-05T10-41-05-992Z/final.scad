$fn = 128;

// Mug dimensions
outer_radius = 40;
inner_radius = 35;
mug_height   = 90;
bottom_thickness = 6;

// Handle dimensions
handle_center_z = mug_height / 2;
opening_height  = 30;
opening_width   = 25;
handle_wall     = 6;
handle_depth    = 12;

// Opening begins just outside the mug body
opening_left_x = outer_radius + 1;

// D-shaped 2D profile:
// left side is straight, right side is semicircular.
module d_profile(left_x, center_z, profile_height, profile_width) {
    r = profile_height / 2;
    arc_center_x = left_x + profile_width - r;

    union() {
        translate([left_x, center_z - r])
            square([arc_center_x - left_x, profile_height]);

        intersection() {
            translate([arc_center_x, center_z])
                circle(r = r, $fn = 128);

            translate([arc_center_x, center_z - r - 1])
                square([r + 1, profile_height + 2]);
        }
    }
}

module mug_body() {
    difference() {
        cylinder(h = mug_height, r = outer_radius);

        translate([0, 0, bottom_thickness])
            cylinder(
                h = mug_height - bottom_thickness + 1,
                r = inner_radius
            );
    }
}

module mug_handle() {
    outer_left_x = opening_left_x - handle_wall;
    outer_height = opening_height + 2 * handle_wall;
    outer_width  = opening_width + 2 * handle_wall;

    rotate([90, 0, 0])
        linear_extrude(
            height = handle_depth,
            center = true,
            convexity = 10
        )
        difference() {
            d_profile(
                outer_left_x,
                handle_center_z,
                outer_height,
                outer_width
            );

            d_profile(
                opening_left_x,
                handle_center_z,
                opening_height,
                opening_width
            );
        }
}

union() {
    mug_body();
    mug_handle();
}