// =====================================================================
// Sharp GP2Y0D413K0F Distance Sensor - Outline Model
// Dimensions from datasheet (Unit: mm)
// Coordinate system: body center at origin,
//   +Z = up (connector down, lenses face front +Y)
// =====================================================================

$fn = 64;

// ---- Main dimensions (from outline drawing) ----
body_w     = 29.45;   // width  (X)  front face length
body_h     = 13.05;   // case height (Z)  (main case block)
body_d     = 7.1;     // case depth (Y)   (7.1 ±0.1)

lenscase_protrude = 2;     // lens case front protrusion (Y)
lenscase_w        = body_w; // lens window region width
lenscase_h        = 8.4;    // lens case height region (Z)

// Lens center positions (X) measured from left edge (light emitter side)
emit_x_from_left = 4.5;    // *4.5  emitter (circular) lens center
det_x_from_left  = 19.7;   // *19.7 detector (rect) lens center

emit_lens_d = 7.0;     // circular emitter window diameter (approx)
det_lens_w  = 7.2;     // rectangular detector window width (approx)
det_lens_h  = 7.2;     // rectangular detector window height (7.2)

// PWB (printed wiring board)
pwb_w     = body_w;
pwb_d     = 10.1;      // PWB depth (Y) reference
pwb_t     = 1.2;       // PWB thickness (Z)

// Overall height from top of case to bottom of PWB/connector ~ 18.9
total_h   = 18.9;

// Connector (JCTC 12001W90-3P-HF) simplified
conn_w    = 16.3 - 7.5; // span between marks ~ 8.8 -> use connector body width
conn_body_w = 8.8;
conn_body_d = 4.15;     // depth-ish
conn_h      = 3.3;      // protrusion below PWB (3.3 ref)
conn_pin_n  = 3;

// =====================================================================
// Derived center offsets
// =====================================================================
emit_cx = emit_x_from_left - body_w/2;   // X position of emitter lens center
det_cx  = det_x_from_left  - body_w/2;   // X position of detector lens center

// =====================================================================
// Modules
// =====================================================================

// Main case block (Carbonic ABS)
module body_case() {
    color("DimGray")
    translate([-body_w/2, -body_d/2, -body_h/2])
        cube([body_w, body_d, body_h]);
}

// Lens case front protrusion with two windows
module lens_case() {
    color("Gray")
    // protruding block on front (+Y) face
    translate([-lenscase_w/2, body_d/2, -lenscase_h/2])
        cube([lenscase_w, lenscase_protrude, lenscase_h]);
}

// Emitter lens (circular window, left)
module emitter_lens() {
    color("Crimson")
    translate([emit_cx, body_d/2 + lenscase_protrude, 0])
        rotate([-90, 0, 0])
            cylinder(d = emit_lens_d, h = 1.0);
}

// Detector lens (rectangular window, right)
module detector_lens() {
    color("DarkRed")
    translate([det_cx - det_lens_w/2,
               body_d/2 + lenscase_protrude,
               -det_lens_h/2])
        cube([det_lens_w, 1.0, det_lens_h]);
}

// PWB (printed wiring board) - thin plate below the case
module pwb() {
    color("ForestGreen")
    translate([-pwb_w/2, -pwb_d/2 + (pwb_d - body_d)/2 - 1.5,
               -body_h/2 - pwb_t])
        cube([pwb_w, pwb_d, pwb_t]);
}

// Connector (3-pin) simplified, below PWB
module connector() {
    pwb_bottom = -body_h/2 - pwb_t;
    // housing
    color("Black")
    translate([-conn_body_w/2, -conn_body_d/2,
               pwb_bottom - conn_h])
        cube([conn_body_w, conn_body_d, conn_h]);
    // 3 pins
    pin_pitch = 2.54;
    color("Goldenrod")
    for (i = [0 : conn_pin_n - 1]) {
        px = (i - (conn_pin_n - 1)/2) * pin_pitch;
        translate([px, 0, pwb_bottom - conn_h - 2.5])
            cube([0.6, 0.6, 5], center = true);
    }
}

// =====================================================================
// Assembly
// =====================================================================
module gp2y0d413k0f() {
    body_case();
    lens_case();
    emitter_lens();
    detector_lens();
    pwb();
    connector();
}

gp2y0d413k0f();