// ============================================================
//  Sharp GP2Y0D413K0F  Distance Measuring Sensor
//  Outline model based on datasheet p.2 "Outline Dimensions"
//
//  Units  : mm
//  Origin : center of the main body case
//  Axes   : +Z = up, +Y = front (lens side), connector at bottom
//
//  Note: dimensions marked "*" in the datasheet are lens-center
//        positions, values in ( ) are reference dimensions.
// ============================================================

$fn = 64;

/* ---------------- datasheet dimensions ---------------- */
BODY_W       = 29.45;          // body width
BODY_D       = 6.3;            // body depth (6.3) reference
BODY_H       = 13.05;          // body case height
TOTAL_D      = 7.1;            // overall depth incl. lens case (7.1 +/-0.1)
LENS_PRJ     = TOTAL_D - BODY_D;   // 0.8 : lens-case protrusion

LENS_CASE_H  = 8.4;            // lens case height
LENS_WIN_H   = 7.2;            // lens window opening height
LENS_TOP_OFS = 2.0;            // lens case top, measured from body top

EMIT_X       = 4.5;            // * emitter lens center from left edge
DET_X        = 19.7;           // * detector lens center from left edge
EMIT_LENS_D  = 3.75;           // emitter lens diameter

PWB_W        = 10.1;           // PWB width
PWB_D        = 6.3;            // PWB depth
PWB_T        = 1.2;            // PWB thickness
PWB_GAP      = 1.35;           // gap between case bottom and PWB
                               //  -> overall height 18.9 (+0.3/-0.3)

CONN_W       = 7.0;            // connector JCTC 12001W90-3P-HF (simplified)
CONN_D       = 4.0;
CONN_H       = 3.3;            // (3.3) reference
PIN_PITCH    = 1.5;

TOTAL_H      = 18.9;           // = BODY_H + PWB_GAP + PWB_T + CONN_H

/* ---------------- derived values ---------------- */
X_L     = -BODY_W/2;                                   // body left edge
FRONT   =  BODY_D/2;                                   // body front face
LENS_Z  =  BODY_H/2 - LENS_TOP_OFS - LENS_CASE_H/2;    // lens center height

LC_X0   = X_L + 1.5;            // lens case left edge
LC_W    = 22.5;                 // lens case width
LC_T    = 1.5;                  // lens case slab thickness (overlaps body)

RWIN_X0 = X_L + 8.5;            // detector rectangular window
RWIN_X1 = X_L + 23.0;
WIN_DEP = 0.6;                  // window recess depth

PWB_Z      = -BODY_H/2 - PWB_GAP - PWB_T/2;            // PWB center Z
CONN_TOP_Z = -BODY_H/2 - PWB_GAP - PWB_T;              // connector top Z

/* ---------------- modules ---------------- */

// main body case (Carbonic ABS)
module main_body() {
    color("DimGray")
        cube([BODY_W, BODY_D, BODY_H], center = true);
}

// lens case protruding from the front face, with two windows
module lens_case() {
    color("DimGray")
    difference() {
        // lens case slab
        translate([LC_X0 + LC_W/2,
                   FRONT + LENS_PRJ - LC_T/2,
                   LENS_Z])
            cube([LC_W, LC_T, LENS_CASE_H], center = true);

        // emitter window (circular, left)
        translate([X_L + EMIT_X,
                   FRONT + LENS_PRJ - WIN_DEP,
                   LENS_Z])
            rotate([-90, 0, 0])
                cylinder(d = EMIT_LENS_D + 0.5, h = WIN_DEP + 0.2);

        // detector window (rectangular, right)
        translate([(RWIN_X0 + RWIN_X1)/2,
                   FRONT + LENS_PRJ - WIN_DEP/2 + 0.1,
                   LENS_Z])
            cube([RWIN_X1 - RWIN_X0, WIN_DEP + 0.2, LENS_WIN_H],
                 center = true);
    }
}

// emitter lens (circular, acrylic, visible-light cut-off)
module emitter_lens() {
    color("DarkSlateBlue", 0.9)
        translate([X_L + EMIT_X,
                   FRONT + LENS_PRJ - WIN_DEP,
                   LENS_Z])
            rotate([-90, 0, 0])
                cylinder(d = EMIT_LENS_D, h = 0.35);
}

// detector lens (rectangular window, right side)
module detector_lens() {
    color("DarkSlateBlue", 0.9)
        translate([(RWIN_X0 + RWIN_X1)/2,
                   FRONT + LENS_PRJ - WIN_DEP + 0.18,
                   LENS_Z])
            cube([RWIN_X1 - RWIN_X0 - 0.5, 0.35, LENS_WIN_H - 0.5],
                 center = true);
}

// legs holding the PWB below the case
module pwb_legs() {
    color("DimGray")
    for (sx = [-1, 1])
        translate([sx * (PWB_W/2 + 0.75),
                   0,
                   -BODY_H/2 - (PWB_GAP + PWB_T)/2])
            cube([1.5, BODY_D, PWB_GAP + PWB_T], center = true);
}

// PWB (paper phenol)
module pwb() {
    color("Tan")
        translate([0, 0, PWB_Z])
            cube([PWB_W, PWB_D, PWB_T], center = true);
}

// 3-pin connector JCTC 12001W90-3P-HF (simplified)
module connector() {
    // housing with downward opening
    color("White")
    difference() {
        translate([0, 0, CONN_TOP_Z - CONN_H/2])
            cube([CONN_W, CONN_D, CONN_H], center = true);
        translate([0, 0, CONN_TOP_Z - CONN_H/2 - 0.6])
            cube([CONN_W - 1.4, CONN_D - 1.4, CONN_H], center = true);
    }
    // 3 pins, 1.5 mm pitch
    color("Gold")
    for (i = [-1 : 1])
        translate([i * PIN_PITCH, 0, CONN_TOP_Z - (CONN_H - 0.4)/2])
            cube([0.4, 0.4, CONN_H - 0.4], center = true);
}

/* ---------------- assembly ---------------- */
module GP2Y0D413K0F() {
    main_body();
    lens_case();
    emitter_lens();
    detector_lens();
    pwb_legs();
    pwb();
    connector();
}

GP2Y0D413K0F();