// Sharp GP2Y0D413K0F distance sensor
// Units: mm
// Coordinate system: body center at origin, lens toward +Y, top +Z

$fn = 64;

body_w = 29.45;
body_d = 7.10;
body_h = 13.05;

lens_case_w = 29.45;
lens_case_d = 2.00;
lens_case_h = 8.40;

body_front = body_d / 2;
lens_front = body_front + lens_case_d;

left_lens_x  = -body_w / 2 + 4.50;
right_lens_x = -body_w / 2 + 19.70;
lens_z = 0;

// PWB
pwb_w = 10.10;
pwb_d = 7.00;
pwb_t = 1.20;
pwb_z = -body_h / 2 - pwb_t / 2;

// Connector
connector_w = 10.10;
connector_d = 3.30;
connector_h = 3.00;
connector_z = -body_h / 2 - pwb_t - connector_h / 2;

// ---------- Utility modules ----------

module y_cylinder(x, y, z, radius, depth, color_name) {
    color(color_name)
        translate([x, y, z])
            rotate([90, 0, 0])
                cylinder(r = radius, h = depth, center = true);
}

module rectangular_lens(x, y, z, w, h, depth, color_name) {
    color(color_name)
        translate([x, y, z])
            cube([w, depth, h], center = true);
}

module pin(x, y, z, diameter = 0.55, length = 2.2) {
    color("gold")
        translate([x, y, z - length / 2])
            cylinder(d = diameter, h = length, center = true);
}

// ---------- Main body ----------

module main_case() {
    color("dimgray")
        translate([0, 0, 0])
            cube([body_w, body_d, body_h], center = true);
}

// ---------- Front lens case ----------

module lens_case() {
    difference() {
        color("black")
            translate([0,
                       body_front + lens_case_d / 2,
                       lens_z])
                cube([lens_case_w, lens_case_d, lens_case_h],
                     center = true);

        // Light emitter opening
        translate([left_lens_x, lens_front, lens_z])
            rotate([90, 0, 0])
                cylinder(r = 2.35, h = 2.6, center = true);

        // Light detector opening
        translate([right_lens_x, lens_front, lens_z])
            cube([8.40, 2.6, 4.50], center = true);
    }

    // Emitter outer retaining ring
    difference() {
        color("black")
            translate([left_lens_x, lens_front + 0.08, lens_z])
                rotate([90, 0, 0])
                    cylinder(r = 2.75, h = 0.28, center = true);

        translate([left_lens_x, lens_front + 0.08, lens_z])
            rotate([90, 0, 0])
                cylinder(r = 2.35, h = 0.40, center = true);
    }

    // Emitter lens
    y_cylinder(left_lens_x, lens_front + 0.15, lens_z,
               2.25, 0.32, "lightblue");

    // Detector retaining frame
    difference() {
        color("black")
            translate([right_lens_x, lens_front + 0.08, lens_z])
                cube([9.80, 0.28, 5.90], center = true);

        translate([right_lens_x, lens_front + 0.08, lens_z])
            cube([8.40, 0.42, 4.50], center = true);
    }

    // Detector lens
    rectangular_lens(right_lens_x, lens_front + 0.15, lens_z,
                     8.15, 4.25, 0.32, "lightblue");
}

// ---------- PWB ----------

module pwb() {
    color("sienna")
        translate([0, 0, pwb_z])
            cube([pwb_w, pwb_d, pwb_t], center = true);
}

// ---------- Bottom connector ----------

module connector() {
    color("black")
        translate([0, -0.25, connector_z])
            cube([connector_w, connector_d, connector_h], center = true);

    // Front connector face
    color("darkgray")
        translate([0, 1.43, connector_z + 0.15])
            cube([connector_w - 0.35, 0.18, connector_h - 0.45],
                 center = true);

    // Three downward terminals
    for (x = [-2.54, 0, 2.54])
        pin(x, 0.0, connector_z - connector_h / 2,
            diameter = 0.55, length = 2.25);
}

// ---------- Assembly ----------

main_case();
lens_case();
pwb();
connector();