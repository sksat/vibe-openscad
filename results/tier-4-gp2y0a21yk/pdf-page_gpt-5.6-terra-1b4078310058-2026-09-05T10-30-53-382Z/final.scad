// Sharp GP2Y0A21YK0F - simplified external model
// Units: mm
// Origin: center of main sensor body
// +Z: upward (lens side)
// +Y: front

$fn = 64;

// -----------------------------------------------------------------------------
// Datasheet dimensions
// -----------------------------------------------------------------------------
body_w          = 29.5;
body_d          = 13.5;
body_h          = 13.0;

overall_w       = 37.0;
overall_d       = 21.5;

mount_hole_d    = 3.2;
mount_outer_d   = 7.5;

lens_spacing    = 20.0;
left_lens_x     = -10.25;   // 4.5 mm from left case edge reference
right_lens_x    =  9.75;

bar_t           = 1.2;
bar_y_center    = -7.0;
bar_y_length    = 8.0;

cable_d         = 3.3;
cable_len       = 34;

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
module rounded_rect_xy(size_x, size_y, radius, height) {
    hull() {
        for (x = [-size_x / 2 + radius, size_x / 2 - radius])
            for (y = [-size_y / 2 + radius, size_y / 2 - radius])
                translate([x, y, 0])
                    cylinder(r = radius, h = height);
    }
}

module horizontal_cylinder_y(diameter, length) {
    rotate([90, 0, 0])
        cylinder(d = diameter, h = length);
}

// -----------------------------------------------------------------------------
// Main optical case
// -----------------------------------------------------------------------------
module sensor_case() {
    difference() {
        union() {
            // Main rectangular case
            translate([-body_w / 2, -2.75, -body_h / 2])
                cube([body_w, body_d, body_h]);

            // Lower case step
            translate([-body_w / 2 + 0.7, -2.45, -body_h / 2 - 0.8])
                cube([body_w - 1.4, body_d - 0.7, 0.8]);

            // Small front upper ridge
            translate([-body_w / 2 + 0.5, 8.8, body_h / 2 - 1.0])
                cube([body_w - 1.0, 1.4, 1.0]);
        }

        // Slight rear lower recess
        translate([-5.1, -2.9, -body_h / 2 - 0.1])
            cube([10.2, 1.5, 2.4]);
    }
}

// -----------------------------------------------------------------------------
// Mounting / connecting bar
// -----------------------------------------------------------------------------
module mounting_bar() {
    difference() {
        union() {
            // Central thin connecting bar
            translate([-body_w / 2, -10.75, -body_h / 2])
                cube([body_w, bar_y_length, bar_t]);

            // Circular mounting ears
            for (x = [-body_w / 2, body_w / 2])
                translate([x, bar_y_center, -body_h / 2])
                    cylinder(d = mount_outer_d, h = bar_t);
        }

        // Two mounting holes
        for (x = [-body_w / 2, body_w / 2])
            translate([x, bar_y_center, -body_h / 2 - 0.1])
                cylinder(d = mount_hole_d, h = bar_t + 0.2);

        // Cable outlet notch at rear edge
        translate([0, -10.85, -body_h / 2 - 0.1])
            cylinder(d = 4.2, h = bar_t + 0.2);
    }
}

// -----------------------------------------------------------------------------
// Lens housings and windows
// -----------------------------------------------------------------------------
module lenses() {
    lens_y = 4.0;
    top_z  = body_h / 2;

    // Emitter lens bezel
    color([0.06, 0.06, 0.06])
    translate([left_lens_x, lens_y, top_z])
        cylinder(d = 8.4, h = 1.5);

    // Emitter lens window
    color([0.20, 0.20, 0.23])
    translate([left_lens_x, lens_y, top_z + 1.45])
        cylinder(d = 6.2, h = 0.7);

    // Detector lens bezel
    color([0.06, 0.06, 0.06])
    translate([right_lens_x, lens_y, top_z])
        rounded_rect_xy(8.4, 8.4, 1.1, 1.5);

    // Detector lens window
    color([0.18, 0.18, 0.21])
    translate([right_lens_x, lens_y, top_z + 1.45])
        rounded_rect_xy(6.3, 6.3, 0.8, 0.7);
}

// -----------------------------------------------------------------------------
// Cable outlet and simplified cable
// -----------------------------------------------------------------------------
module cable() {
    cable_z = -body_h / 2 + bar_t / 2;

    // Strain relief at cable exit
    color([0.08, 0.08, 0.08])
    translate([0, -10.25, cable_z])
        rotate([90, 0, 0])
            cylinder(d = 4.5, h = 3.0);

    // Main cable extending toward -Y
    color([0.12, 0.12, 0.12])
    translate([0, -11.0, cable_z])
        horizontal_cylinder_y(cable_d, cable_len);

    // Downward cable bend at far end
    color([0.12, 0.12, 0.12])
    translate([0, -11.0 - cable_len, cable_z])
        sphere(d = cable_d);

    color([0.12, 0.12, 0.12])
    translate([0, -11.0 - cable_len, cable_z - 16])
        cylinder(d = cable_d, h = 16);
}

// -----------------------------------------------------------------------------
// Assembly
// -----------------------------------------------------------------------------
color([0.10, 0.10, 0.10]) {
    sensor_case();
    mounting_bar();
}

lenses();
cable();