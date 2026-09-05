$fn = 72;

// GP2Y0D413K0F simplified external model
// Origin: center of main body
// +Y: lens/front direction, +Z: upward
// Units: mm

body_w = 29.45;
body_d = 7.1;
body_h = 13.05;

lens_case_h = 8.4;
lens_case_projection = 4.3;
lens_projection = 2.0;

pwb_w = 29.45;
pwb_d = 7.1;
pwb_t = 1.2;

connector_w = 10.1;
connector_d = 5.8;
connector_h = 3.2;
pin_length = 1.45;

case_color = [0.09, 0.09, 0.09];
lens_color = [0.18, 0.12, 0.12, 0.72];
pwb_color = [0.30, 0.25, 0.10];
connector_color = [0.86, 0.86, 0.82];
terminal_color = [0.72, 0.72, 0.68];

module rounded_box(size, radius, center=true) {
    translate(center ? [0,0,0] : size/2)
        minkowski() {
            cube([
                size[0] - 2*radius,
                size[1] - 2*radius,
                size[2] - 2*radius
            ], center=true);
            sphere(r=radius);
        }
}

module main_case() {
    color(case_color)
        cube([body_w, body_d, body_h], center=true);
}

module lens_case() {
    body_front = body_d/2;

    // Shallow front plate joining the two optical housings
    color(case_color)
        translate([0, body_front + 0.5, 0])
            cube([body_w, 1.0, lens_case_h], center=true);

    // Left optical housing: 7.5 mm wide
    color(case_color)
        translate([
            -body_w/2 + 0.85 + 7.5/2,
            body_front + lens_case_projection/2,
            0
        ])
            cube([7.5, lens_case_projection, lens_case_h], center=true);

    // Right optical housing: 16.3 mm wide
    color(case_color)
        translate([
            -body_w/2 + 12.50 + 16.3/2,
            body_front + lens_case_projection/2,
            0
        ])
            cube([16.3, lens_case_projection, lens_case_h], center=true);
}

module emitter_lens() {
    // Reference center: 4.5 mm from the left side
    emitter_x = -body_w/2 + 4.5;
    lens_base_y = body_d/2 + lens_case_projection;

    color(lens_color)
        translate([emitter_x, lens_base_y, 0])
            rotate([-90, 0, 0])
                cylinder(d=6.0, h=lens_projection);
}

module detector_lens() {
    // Reference center: 19.7 mm from the left side
    detector_x = -body_w/2 + 19.7;
    lens_base_y = body_d/2 + lens_case_projection;

    color(lens_color)
        translate([
            detector_x,
            lens_base_y + lens_projection/2,
            0
        ])
            rounded_box(
                [14.8, lens_projection, 7.2],
                0.45,
                center=true
            );
}

module pwb() {
    color(pwb_color)
        translate([0, 0, -body_h/2 - pwb_t/2])
            cube([pwb_w, pwb_d, pwb_t], center=true);
}

module connector() {
    pwb_bottom = -body_h/2 - pwb_t;
    connector_top = pwb_bottom;
    connector_bottom = connector_top - connector_h;

    // Simplified JCTC 12001W90-3P-HF housing
    color(connector_color)
        translate([
            0,
            -0.35,
            (connector_top + connector_bottom)/2
        ])
            cube([connector_w, connector_d, connector_h], center=true);

    // Small front retaining lip
    color(connector_color)
        translate([
            0,
            connector_d/2 - 0.35,
            connector_bottom + 0.65
        ])
            cube([connector_w, 0.7, 1.3], center=true);

    // Three terminals, 2 mm pitch
    for (x = [-2, 0, 2])
        color(terminal_color)
            translate([
                x,
                -0.35,
                connector_bottom - pin_length/2
            ])
                cube([0.50, 0.50, pin_length], center=true);
}

union() {
    main_case();
    lens_case();
    emitter_lens();
    detector_lens();
    pwb();
    connector();
}