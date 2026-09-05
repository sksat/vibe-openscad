// Sharp GP2Y0D413K0F
// Units: mm
// Coordinate system:
//   X = horizontal direction, sensor width
//   Y = vertical direction
//   Z = optical axis
//   Optical/front side = +Z
//   PWB/connector side = -Z
//
// The center of the main sensor body is the origin.

$fn = 64;

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------

body_w       = 29.45;
body_h       = 13.50;
body_d       = 7.10;

body_x0      = -body_w / 2;
body_y0      = -body_h / 2;
body_z0      = -body_d / 2;

emitter_x    = body_x0 + 4.50;
detector_x   = body_x0 + 19.70;

lens_y       = 0;

// Connector
connector_w  = 10.10;
connector_h  = 4.15;
connector_d  = 3.30;

pin_pitch    = 2.54;
pin_w        = 0.55;
pin_h        = 0.55;
pin_len      = 3.30;

// -----------------------------------------------------------------------------
// Utility modules
// -----------------------------------------------------------------------------

module rounded_box(size = [10,10,10], radius = 1, center = true) {
    x = size[0];
    y = size[1];
    z = size[2];

    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        minkowski() {
            cube([
                max(0.01, x - 2*radius),
                max(0.01, y - 2*radius),
                max(0.01, z - 2*radius)
            ], center = true);
            sphere(r = radius, $fn = 24);
        }
}

module cylinder_z(d, h, x, y, z, color_name = "black") {
    color(color_name)
        translate([x,y,z])
            cylinder(d = d, h = h, center = false);
}

module box_at(size, pos, color_name = "black", radius = 0) {
    color(color_name)
        translate(pos)
            if (radius > 0)
                rounded_box(size, radius, center = true);
            else
                cube(size, center = true);
}

// -----------------------------------------------------------------------------
// Main housing
// -----------------------------------------------------------------------------

module main_housing() {
    // Carbonic ABS housing
    color("black")
        rounded_box([body_w, body_h, body_d], radius = 0.55, center = true);

    // Slightly raised front face / optical bezel
    box_at(
        [body_w - 0.70, body_h - 0.80, 0.45],
        [0, 0, body_d/2 + 0.18],
        "black",
        0.28
    );

    // Rear relief area around connector
    box_at(
        [body_w - 2.0, body_h - 2.0, 0.35],
        [0, 0, -body_d/2 - 0.16],
        "black",
        0.20
    );
}

// -----------------------------------------------------------------------------
// Emitter optical assembly
// -----------------------------------------------------------------------------

module emitter() {
    // Rectangular optical surround
    box_at(
        [5.80, 8.40, 0.70],
        [emitter_x, lens_y, body_d/2 + 0.35],
        "black",
        0.22
    );

    // Lens retaining ring
    color("darkgray")
        translate([emitter_x, lens_y, body_d/2 + 0.70])
            cylinder(d = 4.65, h = 0.38);

    // Infrared emitting lens
    color([0.45, 0.04, 0.025, 0.88])
        translate([emitter_x, lens_y, body_d/2 + 1.02])
            cylinder(d = 3.65, h = 0.62);

    // Small central emitter surface
    color([0.12, 0.01, 0.005, 0.95])
        translate([emitter_x, lens_y, body_d/2 + 1.61])
            cylinder(d = 2.20, h = 0.06);
}

// -----------------------------------------------------------------------------
// Detector optical assembly
// -----------------------------------------------------------------------------

module detector() {
    detector_case_w = 14.00;
    detector_case_h = 8.40;

    // Rectangular detector lens case
    box_at(
        [detector_case_w, detector_case_h, 0.78],
        [detector_x, lens_y, body_d/2 + 0.39],
        "black",
        0.30
    );

    // Inner visible lens window
    box_at(
        [detector_case_w - 1.20, detector_case_h - 1.10, 0.22],
        [detector_x, lens_y, body_d/2 + 0.86],
        "darkgray",
        0.18
    );

    // Circular visible detector lens
    color([0.055, 0.075, 0.080, 0.95])
        translate([detector_x, lens_y, body_d/2 + 0.98])
            cylinder(d = 5.05, h = 0.34);

    // Lens highlight / inner surface
    color([0.14, 0.18, 0.19, 0.80])
        translate([detector_x, lens_y, body_d/2 + 1.30])
            cylinder(d = 3.85, h = 0.08);
}

// -----------------------------------------------------------------------------
// Connector on the -Z side
// -----------------------------------------------------------------------------

module connector() {
    connector_z = -body_d/2 - connector_d/2;

    // Black connector housing
    box_at(
        [connector_w, connector_h, connector_d],
        [0, 0, connector_z],
        "black",
        0.28
    );

    // Connector face insert
    box_at(
        [connector_w - 0.80, connector_h - 0.70, 0.18],
        [0, 0, -body_d/2 - connector_d - 0.02],
        "darkgray",
        0.12
    );

    // Three electrical terminals, numbered 1, 2, 3 from left to right.
    for (i = [-1, 0, 1]) {
        x = i * pin_pitch;

        color("silver")
            translate([x, 0, -body_d/2 - connector_d - pin_len/2])
                cube([pin_w, pin_h, pin_len], center = true);

        // Slightly visible terminal entry at the connector face
        color("gray")
            translate([x, 0, -body_d/2 - connector_d - 0.11])
                cube([pin_w + 0.08, pin_h + 0.08, 0.20], center = true);
    }
}

// -----------------------------------------------------------------------------
// Rear PWB indication
// -----------------------------------------------------------------------------

module pwb() {
    // Thin paper-phenol PWB immediately behind the sensor housing.
    // It is kept narrow so the connector remains visible.
    color([0.18, 0.08, 0.025])
        translate([0, 0, -body_d/2 - 0.10])
            cube([body_w - 2.0, body_h - 2.0, 0.16], center = true);
}

// -----------------------------------------------------------------------------
// Optional side mounting ledges
// -----------------------------------------------------------------------------

module side_ledges() {
    // Small lower side shoulders suggested by the outline drawing
    box_at(
        [6.20, 1.25, 0.70],
        [-10.45, -body_h/2 - 0.38, -0.10],
        "black",
        0.15
    );

    box_at(
        [6.20, 1.25, 0.70],
        [10.45, -body_h/2 - 0.38, -0.10],
        "black",
        0.15
    );
}

// -----------------------------------------------------------------------------
// Complete sensor
// -----------------------------------------------------------------------------

module GP2Y0D413K0F() {
    main_housing();
    side_ledges();
    emitter();
    detector();
    connector();
    pwb();
}

GP2Y0D413K0F();