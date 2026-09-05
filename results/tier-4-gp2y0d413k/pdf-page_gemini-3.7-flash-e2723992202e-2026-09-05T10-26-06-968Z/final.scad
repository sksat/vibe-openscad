// Sharp GP2Y0D413K0F Distance Measuring Sensor
// Units in mm, Origin at the center of the main case body

$fn = 40;

// Dimensions from datasheet
body_w = 29.45;
body_d = 7.1;
body_h = 13.05;

lens_case_h_base = 8.4;
lens_case_h_tip  = 7.2;
lens_case_ext_base = 4.3; // 6.3 - 2.0
lens_case_ext_tip  = 2.0;

// Lens center positions (from left edge: *4.5mm and *19.7mm spacing)
x_left = -body_w / 2;
x_emitter  = x_left + 4.5;          // -10.225
x_detector = x_emitter + 19.7;      // +9.475

// Colors
col_case      = [0.18, 0.18, 0.18]; // Carbonic ABS (conductive resin)
col_lens      = [0.25, 0.05, 0.08, 0.85]; // Acrylic visible light cut-off resin
col_pwb       = [0.45, 0.32, 0.15]; // Paper phenol
col_connector = [0.92, 0.90, 0.82]; // JCTC connector housing
col_pin       = [0.85, 0.75, 0.30]; // Metal pins

module main_case() {
    color(col_case) {
        difference() {
            // Main body block
            cube([body_w, body_d, body_h], center=true);
            
            // Bottom cutout for PWB & connector
            translate([0, -body_d/4, -body_h/2])
                cube([body_w + 1, body_d/2 + 0.1, 2.5], center=true);
        }
    }
}

module lens_case() {
    color(col_case) {
        // Base protrusion of lens case
        translate([0, body_d/2 + lens_case_ext_base/2, 0])
            cube([body_w - 2, lens_case_ext_base, lens_case_h_base], center=true);
        
        // Emitter hood (Left)
        translate([x_emitter, body_d/2 + lens_case_ext_base + lens_case_ext_tip/2, 0])
            difference() {
                cube([7.5, lens_case_ext_tip, lens_case_h_tip], center=true);
                // Aperture cutout
                translate([0, 0.5, 0])
                    rotate([90, 0, 0])
                        cylinder(d=5.6, h=lens_case_ext_tip + 1, center=true);
            }

        // Detector hood (Right)
        translate([x_detector, body_d/2 + lens_case_ext_base + lens_case_ext_tip/2, 0])
            difference() {
                cube([9.5, lens_case_ext_tip, lens_case_h_tip], center=true);
                // Rectangular aperture cutout
                translate([0, 0.5, 0])
                    cube([7.5, lens_case_ext_tip + 1, 5.2], center=true);
            }
    }
}

module lenses() {
    color(col_lens) {
        // Emitter Lens (Circular convex)
        translate([x_emitter, body_d/2 + lens_case_ext_base + 0.5, 0])
            rotate([90, 0, 0])
                cylinder(d=5.4, h=2.0, center=true);

        // Detector Lens (Rectangular / Cylindrical)
        translate([x_detector, body_d/2 + lens_case_ext_base + 0.5, 0])
            cube([7.3, 2.0, 5.0], center=true);
    }
}

module pwb() {
    color(col_pwb) {
        // PWB plate on bottom rear
        translate([0, -body_d/2 + 1.2/2, -body_h/2 - 1.5/2])
            cube([body_w - 1.0, 1.2, 3.5], center=true);
    }
}

module connector() {
    conn_w = 10.1;
    conn_d = 3.3;
    conn_h = 5.85; // 18.9 (total height) - 13.05 (body height)
    
    // Housing
    color(col_connector) {
        translate([0, -body_d/2 + 1.2 + conn_d/2, -body_h/2 - conn_h/2]) {
            difference() {
                cube([conn_w, conn_d, conn_h], center=true);
                // Cavity
                translate([0, 0.4, -0.6])
                    cube([conn_w - 1.6, conn_d - 0.8, conn_h - 1.0], center=true);
                // Key notch on front
                translate([0, conn_d/2, -1.0])
                    cube([3.5, 1.0, conn_h], center=true);
            }
        }
    }

    // 3 Pins (1: Vo, 2: GND, 3: Vcc) - Pitch ~ 1.5mm
    color(col_pin) {
        for (i = [-1:1]) {
            translate([i * 1.5, -body_d/2 + 1.2 + conn_d/2 + 0.2, -body_h/2 - conn_h/2 - 0.5])
                cube([0.5, 0.5, conn_h - 1.5], center=true);
        }
    }
}

// Top-level assembly
module gp2y0d413k0f() {
    main_case();
    lens_case();
    lenses();
    pwb();
    connector();
}

gp2y0d413k0f();