$fn = 96;

// Mug dimensions
outer_d = 80;
inner_d = 70;
outer_r = outer_d / 2;
inner_r = inner_d / 2;
height = 90;
bottom_thickness = 6;

// Handle dimensions/orientation
handle_gap_w = 25;      // inner opening width (radial, X direction)
handle_gap_h = 30;      // inner opening height (Z direction)
handle_thickness = 5;   // handle band thickness
handle_center_z = height / 2;

// Derived handle geometry (YZ-plane profile, then extruded in X)
handle_inner_r = handle_gap_h / 2;                  // 15
handle_outer_r = handle_inner_r + handle_thickness; // 20
handle_attach_x = outer_r - 0.8;                    // slight embed into mug for robust union
handle_outer_x = handle_attach_x + handle_gap_w + handle_thickness;
handle_total_x = handle_outer_x - handle_attach_x;

module mug_body() {
    difference() {
        cylinder(h = height, r = outer_r);
        translate([0, 0, bottom_thickness])
            cylinder(h = height - bottom_thickness + 0.1, r = inner_r);
    }
}

module handle_profile_2d() {
    difference() {
        union() {
            translate([0, handle_center_z])
                intersection() {
                    circle(r = handle_outer_r);
                    translate([0, -handle_outer_r])
                        square([handle_outer_r, 2 * handle_outer_r], center = false);
                }
            translate([-handle_thickness, handle_center_z - handle_outer_r])
                square([handle_thickness, 2 * handle_outer_r], center = false);
        }

        union() {
            translate([0, handle_center_z])
                intersection() {
                    circle(r = handle_inner_r);
                    translate([0, -handle_inner_r])
                        square([handle_inner_r, 2 * handle_inner_r], center = false);
                }
            translate([-handle_thickness - 0.1, handle_center_z - handle_inner_r])
                square([handle_thickness + 0.2, 2 * handle_inner_r], center = false);
        }
    }
}

module handle() {
    translate([handle_attach_x, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height = handle_total_x, center = false, convexity = 10)
                handle_profile_2d();
}

union() {
    mug_body();
    handle();
}