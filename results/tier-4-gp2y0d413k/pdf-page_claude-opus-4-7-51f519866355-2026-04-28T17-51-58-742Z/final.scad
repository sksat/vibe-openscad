// Sharp GP2Y0D413K0F Distance Sensor Outline Model
// Coordinate system: origin at body center
// +Z up (connector below), +Y front (lens face)
// Units: mm

// ---- Main body dimensions ----
body_width  = 29.45;   // X (along light emitter to detector)
body_depth  = 7.1;     // Y (front-back without lens case)
body_height = 13.05;   // Z

// ---- Lens case (front protrusion) ----
lens_case_w     = 29.45;   // approx along X (slightly less, but use body width)
lens_case_protr = 2.0;     // protrudes ~2 mm from body front
lens_case_h     = 8.4;     // height of lens-case region

// ---- Lens positions (from left edge) ----
emitter_x_from_left  = 4.5;    // *4.5
detector_x_from_left = 4.5 + 19.7; // *19.7 between centers
// In centered coord:
emitter_x  = -body_width/2 + emitter_x_from_left;
detector_x = -body_width/2 + detector_x_from_left;

// ---- Lens dimensions (visible window) ----
emitter_lens_dia   = 4.0;   // circular emitter window (approx)
detector_lens_w    = 6.0;   // rectangular detector window width
detector_lens_h    = 6.0;   // detector window height

// ---- PWB ----
pwb_w = 29.45;
pwb_d = 7.1 + 3.3;   // roughly extends a bit; use body depth + small
pwb_t = 1.2;         // thickness

// Total height from PWB bottom to top of body = 18.9
// body_height (13.05) + pwb_t (1.2) = 14.25; remaining ~4.65 is connector region
total_h = 18.9;

// ---- Connector ----
conn_w = 7.5;       // approx (4.15 + some)
conn_d = 4.15;
conn_h = total_h - body_height - pwb_t;  // ~4.65
conn_x_from_left = 7.5 + 4.15/2; // approximate center
conn_x = -body_width/2 + 7.5 + 4.15/2;

// =====================================================
// MODULES
// =====================================================

module main_body() {
    color("DimGray")
    translate([-body_width/2, -body_depth/2, -body_height/2])
        cube([body_width, body_depth, body_height]);
}

module lens_case() {
    // Protrudes in +Y direction
    color("DimGray")
    translate([-lens_case_w/2, body_depth/2, -lens_case_h/2])
        cube([lens_case_w, lens_case_protr, lens_case_h]);
}

module emitter_lens() {
    // Circular window on lens case front
    color("Black")
    translate([emitter_x, body_depth/2 + lens_case_protr - 0.01, 0])
        rotate([-90, 0, 0])
            cylinder(h = 0.8, d = emitter_lens_dia, $fn = 48);
}

module detector_lens() {
    // Rectangular window on lens case front
    color("Black")
    translate([detector_x - detector_lens_w/2,
               body_depth/2 + lens_case_protr - 0.01,
               -detector_lens_h/2])
        cube([detector_lens_w, 0.8, detector_lens_h]);
}

module pwb() {
    // Printed Wiring Board, thin plate beneath body
    color("DarkGreen")
    translate([-pwb_w/2, -body_depth/2, -body_height/2 - pwb_t])
        cube([pwb_w, pwb_d, pwb_t]);
}

module connector() {
    // Simplified 3-pin connector below PWB
    conn_body_w = 7.5;
    conn_body_d = 4.15;
    color("Ivory")
    translate([-body_width/2 + 7.5,
               -conn_body_d/2,
               -body_height/2 - pwb_t - conn_h])
        cube([conn_body_w, conn_body_d, conn_h]);

    // 3 pins underneath (visualization)
    pin_dia = 0.6;
    pin_len = 2.0;
    pin_pitch = 1.5;
    pin_center_x = -body_width/2 + 7.5 + 7.5/2;
    for (i = [-1, 0, 1]) {
        color("Gold")
        translate([pin_center_x + i * pin_pitch, 0,
                   -body_height/2 - pwb_t - conn_h - pin_len/2])
            cylinder(h = pin_len, d = pin_dia, center = true, $fn = 16);
    }
}

// =====================================================
// ASSEMBLY
// =====================================================
module gp2y0d413k0f() {
    main_body();
    lens_case();
    emitter_lens();
    detector_lens();
    pwb();
    connector();
}

gp2y0d413k0f();