// Sharp GP2Y0D413K0F Distance Sensor - Outline Model
// Coordinate system: center of main body at origin, +Z up, +Y toward lens front
// Units: mm

// ─── Key dimensions from datasheet ───────────────────────────────────────────

// Main body (Carbonic ABS case)
body_w = 29.45;   // width  (X)  – overall width shown as 29.45
body_h = 13.05;   // height (Z)  – 13.05 shown on right side view
body_d = 13.5;    // depth  (Y)  – read from bottom view (~13.5 estimated)
// The drawing shows 18.9 as the total height including PWB protrusion area;
// 13.05 is the case body height, 1.2 is PWB thickness, (3.3) connector below.

// PWB (printed wiring board) – sits below the main body
pwb_w  = 29.45;   // same width as body
pwb_d  = 13.5;    // same depth as body
pwb_t  = 1.2;     // thickness  (Z)

// Connector (JCTC 12001W90-3P-HF) – 3-pin, below PWB
// Bottom view shows pin spacing area: 7.5 + 4.15 + ... = widths
// Connector body approx: width 10.1, depth ~8.4, height (3.3)
conn_w = 10.1;
conn_d = 8.4;
conn_h = 3.3;     // (reference)
pin_pitch = 2.54; // standard 2.54 mm pitch for 3 pins
pin_w  = 0.6;
pin_d  = 0.3;
pin_h  = 3.5;     // length protruding below connector

// Lens case protrusion on the front face (+Y)
// From front view: total width 29.45, lens case protrudes forward
// Lens case height: roughly 8.4 (from 8.4 dimension in side view)
// Lens case width: contains both lenses; *4.5 and *19.7 are lens center X positions
//   (measured from left edge of body, so left lens center at x=4.5, right at x=19.7)
// Lens case depth (protrusion): ~7.1 ± 0.1 (from side view dimension 7.1±0.1)
// Lens case vertical center: approximately at 7.2 from bottom of body (side view shows 7.2)
lens_case_w    = 29.45;  // spans full width
lens_case_h    = 8.4;    // height of lens case
lens_case_d    = 7.1;    // protrusion depth beyond front face
lens_case_z_bot = 7.2;   // bottom of lens case above body bottom

// Lens positions (center X from LEFT edge of body)
emitter_cx_from_left  = 4.5;   // *4.5
detector_cx_from_left = 19.7;  // *19.7

// Convert to body-centered X coordinates
// body left edge is at x = -body_w/2
emitter_cx  = -body_w/2 + emitter_cx_from_left;   // = -14.725 + 4.5  = -10.225
detector_cx = -body_w/2 + detector_cx_from_left;  // = -14.725 + 19.7 =  4.975

// Lens center Z (from body bottom)
lens_cz_from_bot = lens_case_z_bot + lens_case_h/2;  // approx middle of lens case

// Emitter lens: circular, diameter ~5.5 (estimated from drawing proportions)
emitter_lens_r = 2.75;

// Detector lens: rectangular window, approx 6.3 wide x 6.3 tall (6.3 from drawing)
detector_lens_w = 6.3;
detector_lens_h = 6.3;

// ─── Derived Z coordinates ────────────────────────────────────────────────────
// Layout from bottom up:
//   connector pins protrude below PWB
//   PWB bottom at z = -body_h/2 - pwb_t
//   body bottom at z = -body_h/2
//   body top    at z = +body_h/2

body_bot_z = -body_h / 2;
body_top_z =  body_h / 2;
pwb_bot_z  = body_bot_z - pwb_t;
conn_bot_z = pwb_bot_z  - conn_h;

lens_case_bot_z = body_bot_z + lens_case_z_bot;
lens_case_top_z = lens_case_bot_z + lens_case_h;
lens_cz = (lens_case_bot_z + lens_case_top_z) / 2;

// Front face of body is at y = +body_d/2
body_front_y = body_d / 2;
lens_case_front_y = body_front_y + lens_case_d;

// ─── Modules ──────────────────────────────────────────────────────────────────

module main_body() {
    color("DimGray")
    translate([0, 0, 0])
    cube([body_w, body_d, body_h], center=true);
}

module lens_case() {
    color("DarkGray") {
        // Lens case block – protrudes from front face
        translate([0,
                   body_front_y + lens_case_d/2,
                   lens_case_bot_z + lens_case_h/2])
            cube([lens_case_w, lens_case_d, lens_case_h], center=true);
    }
}

module emitter_lens() {
    // Circular lens window (light emitter, left side)
    color("Black")
    translate([emitter_cx,
               lens_case_front_y + 0.5,
               lens_cz])
        rotate([90, 0, 0])
            cylinder(r=emitter_lens_r, h=2, center=true, $fn=48);
}

module detector_lens() {
    // Rectangular lens window (light detector, right side)
    color("Black")
    translate([detector_cx,
               lens_case_front_y + 0.5,
               lens_cz])
        rotate([90, 0, 0])
            cube([detector_lens_w, detector_lens_h, 2], center=true);
}

module pwb() {
    color("SaddleBrown", 0.9)
    translate([0, 0, pwb_bot_z + pwb_t/2])
        cube([pwb_w, pwb_d, pwb_t], center=true);
}

module connector_body() {
    // Connector body – centered under the PWB, slightly offset toward front
    // From bottom view: connector is centered around x≈ +4 from body center (10.1 wide)
    // Position: roughly centered on the PWB
    color("Black")
    translate([0, 0, conn_bot_z + conn_h/2])
        cube([conn_w, conn_d, conn_h], center=true);
}

module connector_pins() {
    // 3 through-hole pins protruding downward
    pin_spacing = 2.54;
    color("Silver")
    for (i = [-1, 0, 1]) {
        translate([i * pin_spacing,
                   0,
                   conn_bot_z - pin_h/2])
            cube([pin_w, pin_d, pin_h], center=true);
    }
}

// ─── Assembly ─────────────────────────────────────────────────────────────────

union() {
    main_body();
    lens_case();

    // Subtract lens windows from lens case (difference)
    difference() {
        union() { } // nothing to add here; lenses subtracted below
    }

    pwb();
    connector_body();
    connector_pins();
}

// Lens case with cutouts for lenses
difference() {
    union() {
        // (already drawn above – redraw here as the base for subtraction)
    }
}

// Rebuild properly with difference for lens windows
module sensor_assembly() {
    // Main body
    main_body();

    // Lens case with lens apertures cut out
    difference() {
        lens_case();
        emitter_lens();
        detector_lens();
    }

    // PWB
    pwb();

    // Connector
    connector_body();
    connector_pins();
}

// ─── Render ───────────────────────────────────────────────────────────────────
sensor_assembly();