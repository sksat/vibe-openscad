// Sharp GP2Y0A21YK0F distance sensor outline model
// Datasheet sheet 2 "Outline Dimensions" (Unit: mm)
//
// Coordinate system:
//   - Origin at body center
//   - +Z up (lenses on top face)
//   - +Y forward
//
// Notes:
//   - Dimensions marked * in datasheet are lens-center reference dims
//   - ( ) values are reference
//   - Unspecified tolerance +/-0.3 mm

$fn = 64;

// ---- Key dimensions from datasheet ----
body_w        = 29.5;   // main lens-case body width (X)
body_d        = 13.0;   // body depth (Y) (lens case)
body_h        = 13.5;   // overall case height
lens_top_h    = 18.9;   // total height incl. lens protrusion (reference)

bar_total_w   = 37.0;   // overall width across mounting tabs
bar_h         = 7.2;    // connecting-bar thickness / height region
bar_d         = 2.0;    // thin plate-like bar thickness (front extension ~)

mount_pitch   = 37.0 - 2*3.75; // center-to-center mounting hole span approx
mount_hole_d  = 3.2;    // mounting holes diameter
mount_tab_r   = 3.75;   // R3.75 rounded tab radius

lens_spacing  = 20.0;   // * lens center to lens center
lens_off      = 4.5;    // * first lens center from left edge ref

emitter_d     = 6.3;    // emitter lens window related dim
detector_w    = 10.1;   // detector window region width
detector_open = 14.75;  // detector opening reference

cable_notch_w = 7.5;    // cable take-out region
cable_d       = 4.0;    // simplified cable diameter

// ===========================================================
// Main lens-case body
// ===========================================================
module lens_case() {
    color([0.25, 0.25, 0.25])
    translate([0, 0, 0])
        cube([body_w, body_d, body_h], center = true);
}

// ===========================================================
// Lens protrusion on top: emitter + detector windows
// ===========================================================
module lenses() {
    lens_protrude = lens_top_h - body_h; // ~5.4
    z_base = body_h/2;

    // emitter lens (circular window), left side
    color([0.15, 0.15, 0.2])
    translate([-lens_spacing/2, 0, z_base])
        cylinder(d = emitter_d, h = lens_protrude);

    // detector lens (rounded rectangular window), right side
    color([0.15, 0.15, 0.2])
    translate([ lens_spacing/2, 0, z_base + lens_protrude/2])
        minkowski() {
            cube([detector_w - 2, body_d - 4, lens_protrude - 0.01],
                 center = true);
            cylinder(r = 1, h = 0.005);
        }
}

// ===========================================================
// Connecting bar with rounded mounting tabs
// ===========================================================
module mount_tab(x_sign) {
    color([0.25, 0.25, 0.25])
    difference() {
        // rounded tab body
        translate([x_sign * (bar_total_w/2 - mount_tab_r), 0, 0])
        union() {
            cylinder(r = mount_tab_r, h = bar_h, center = true);
            // join toward body
            translate([-x_sign * mount_tab_r/2, 0, 0])
                cube([mount_tab_r, mount_tab_r*2, bar_h], center = true);
        }
        // mounting hole
        translate([x_sign * (bar_total_w/2 - mount_tab_r), 0, 0])
            cylinder(d = mount_hole_d, h = bar_h + 1, center = true);
    }
}

module connecting_bar() {
    z_bar = -(body_h/2) + bar_h/2; // bar sits at lower region of case

    translate([0, 0, z_bar]) {
        // central connecting plate linking tabs to body
        color([0.25, 0.25, 0.25])
        difference() {
            cube([bar_total_w - 2, mount_tab_r*1.8, bar_h], center = true);
            // cable take-out notch at front-center
            translate([0, mount_tab_r, 0])
                cube([cable_notch_w, mount_tab_r*2, bar_h + 1], center = true);
        }
        // rounded mounting tabs left / right
        mount_tab(-1);
        mount_tab( 1);
    }
}

// ===========================================================
// Cable (simplified rod) exiting front-bottom (PHR-3 lead)
// ===========================================================
module cable() {
    z_cable = -(body_h/2) + bar_h/2;
    color([0.1, 0.1, 0.1])
    translate([0, body_d/2, z_cable])
        rotate([-90, 0, 0])
            cylinder(d = cable_d, h = 12);
}

// ===========================================================
// Assembly
// ===========================================================
module GP2Y0A21YK0F() {
    lens_case();
    lenses();
    connecting_bar();
    cable();
}

GP2Y0A21YK0F();