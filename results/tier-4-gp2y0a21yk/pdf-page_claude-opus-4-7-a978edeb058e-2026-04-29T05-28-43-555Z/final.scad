// Sharp GP2Y0A21YK0F distance sensor - external dimensions model
// Origin at body center. +Z up (lens on top), +Y forward.
// Units: mm

$fn = 64;

// --- Main dimensions (from datasheet) ---
body_len      = 29.5;   // main lens-case body length (X)
body_depth    = 13.0;   // body depth in Y (front-back, 13 from side view)
body_height   = 13.5 - 1.2 - 3.3; // case height above bar... use side view: total ~18.9 incl lens, case ~13.5 - PWB
// Use simpler decomposition based on side view:
case_h        = 13.5;   // case height (back/side view shows 13.5)
lens_proj_h   = 18.9 - 13.5; // lens protrusion above case top (~5.4)
// horizontal extents
total_len     = 37.0;   // tip-to-tip including mounting tabs
bar_thick     = 2.0;    // connecting bar (mounting tab) thickness in Z
bar_y         = 8.4;    // bar depth in Y at mounting region (approx)
mount_hole_d  = 3.2;
mount_pitch   = 37.0 - 2*3.75; // distance between hole centers approx? Actually holes are at outer ends.
// From figure: R3.75 ends, total 37, so hole centers near each end.
hole_center_offset = (total_len/2) - 3.75; // 14.75 from center

// Lens centers (from datasheet): *4.5 from one side edge of body, *20±0.1 between centers
// Body length 29.5, so lens centers symmetric around center: ±10
lens_spacing  = 20.0;
emitter_x     = -lens_spacing/2;
detector_x    =  lens_spacing/2;

// Lens window sizes (approx from drawing)
emitter_lens_d = 7.0;     // round emitter lens
detector_lens_w = 10.0;   // detector window width
detector_lens_h = 7.0;    // detector window depth (Y)

// Cable
cable_d = 2.5;
cable_len = 40;

// --- Build ---

module main_body() {
    // Main rectangular case (lens housing)
    translate([-body_len/2, -body_depth/2, -case_h/2])
        cube([body_len, body_depth, case_h]);
}

module mounting_bar() {
    // Thin bar extending sideways with mounting tabs (rounded ends)
    // The bar sits roughly at middle height of body; thickness ~2mm
    bar_z_center = -case_h/2 + bar_thick/2 + 4; // approx vertical position
    translate([0, 0, bar_z_center])
    linear_extrude(height = bar_thick, center = true) {
        hull() {
            translate([-hole_center_offset, 0]) circle(r = 3.75);
            translate([ hole_center_offset, 0]) circle(r = 3.75);
        }
    }
}

module mounting_holes() {
    bar_z_center = -case_h/2 + bar_thick/2 + 4;
    for (sx = [-1, 1]) {
        translate([sx * hole_center_offset, 0, bar_z_center])
            cylinder(d = mount_hole_d, h = bar_thick + 2, center = true);
    }
}

module cable_notch() {
    // Cable exit on the back (-Y) side, near bottom
    translate([0, -body_depth/2 - 2, -case_h/2 + 3])
        cube([6.3, 4, 4], center = true);
}

module emitter_lens() {
    // Round lens protruding from top
    translate([emitter_x, 0, case_h/2])
        cylinder(d = emitter_lens_d, h = lens_proj_h);
    // small dome
    translate([emitter_x, 0, case_h/2 + lens_proj_h])
        sphere(d = emitter_lens_d * 0.9);
}

module detector_lens() {
    // Rectangular window protruding from top
    translate([detector_x, 0, case_h/2])
        translate([-detector_lens_w/2, -detector_lens_h/2, 0])
            cube([detector_lens_w, detector_lens_h, lens_proj_h]);
}

module cable() {
    // Simple cylindrical cable coming out the back
    translate([0, -body_depth/2 - cable_len/2 - 1, -case_h/2 + 3])
        rotate([90, 0, 0])
            cylinder(d = cable_d, h = cable_len, center = true);
}

module sensor() {
    difference() {
        union() {
            main_body();
            mounting_bar();
            emitter_lens();
            detector_lens();
        }
        mounting_holes();
        cable_notch();
    }
    cable();
}

sensor();