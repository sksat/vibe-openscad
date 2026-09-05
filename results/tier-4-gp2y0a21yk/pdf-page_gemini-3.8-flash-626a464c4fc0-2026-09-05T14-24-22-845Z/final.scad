// Sharp GP2Y0A21YK0F Distance Measuring Sensor
// Dimensions in mm

$fn = 40;

// ================= Dimensions =================
// Main body
body_w = 29.5;
body_h = 8.4;
body_total_d = 13.5; // Front of lens to back of PWB

// Z-coordinates (origin at center of main body envelope)
z_front_lens = body_total_d / 2;          // +6.75
z_front_case = z_front_lens - 2.0;        // +4.75
z_flange_front = z_front_lens - 6.3;      // +0.45
z_flange_back = z_flange_front - 1.5;     // -1.05
z_pwb_back = -body_total_d / 2;           // -6.75
z_pwb_front = z_pwb_back + 1.2;           // -5.55

// Flange & Mounting holes
hole_pitch = 37.0;
hole_dia = 3.2;
flange_r = 3.75;
flange_t = 1.5;

// Lens & Front features
lens_win_h = 7.2;
emitter_w = 7.5;
emitter_x = -body_w/2 + 4.5;              // -10.25 (Note 1 lens center)
detector_w = 16.3;
detector_x = emitter_x + 20.0;            // +9.75 (20mm pitch)

// PWB & Connector
pwb_total_h = 13.0; // From top of body to bottom of PWB
pwb_drop = pwb_total_h - body_h/2;        // Distance below Y=0
conn_w = 10.1;
conn_total_h = 18.9;                      // From top of body to bottom of connector
conn_bottom_y = body_h/2 - conn_total_h;  // -14.7

// Colors
col_case = [0.18, 0.18, 0.18];
col_lens = [0.25, 0.05, 0.10, 0.85];
col_pwb  = [0.65, 0.45, 0.22];
col_conn = [0.92, 0.92, 0.88];
col_pin  = [0.85, 0.75, 0.30];

// ================= Modules =================

module mounting_flanges() {
    difference() {
        union() {
            // Left ear
            hull() {
                translate([-body_w/2, -body_h/2, z_flange_back])
                    cube([0.1, body_h, flange_t]);
                translate([-hole_pitch/2, 0, z_flange_back])
                    cylinder(r = flange_r, h = flange_t);
            }
            // Right ear
            hull() {
                translate([body_w/2 - 0.1, -body_h/2, z_flange_back])
                    cube([0.1, body_h, flange_t]);
                translate([hole_pitch/2, 0, z_flange_back])
                    cylinder(r = flange_r, h = flange_t);
            }
        }
        // Screw holes
        translate([-hole_pitch/2, 0, z_flange_back - 1])
            cylinder(d = hole_dia, h = flange_t + 2);
        translate([hole_pitch/2, 0, z_flange_back - 1])
            cylinder(d = hole_dia, h = flange_t + 2);
    }
}

module main_case() {
    color(col_case) {
        // Front main block (between flange and lens bezel)
        translate([-body_w/2, -body_h/2, z_flange_front])
            cube([body_w, body_h, z_front_case - z_flange_front]);

        // Rear case body (between flange and PWB)
        translate([-body_w/2, -body_h/2, z_pwb_front])
            cube([body_w, body_h, z_flange_back - z_pwb_front]);

        // Flanges
        mounting_flanges();

        // Front lens bezels (hoods protruding forward by 2mm)
        // Emitter bezel
        translate([emitter_x - emitter_w/2, -lens_win_h/2, z_front_case])
            cube([emitter_w, lens_win_h, 2.0]);

        // Detector bezel
        translate([detector_x - detector_w/2 + 2.75, -lens_win_h/2, z_front_case])
            cube([detector_w, lens_win_h, 2.0]);
    }
}

module lenses() {
    color(col_lens) {
        // Light Emitter Lens (Spherical convex)
        translate([emitter_x, 0, z_front_lens - 0.3]) {
            intersection() {
                scale([1, 1, 0.6]) sphere(d = 5.5);
                translate([-3, -3, 0]) cube([6, 6, 2]);
            }
        }

        // Light Detector Lens (Aspheric / Cylindrical convex)
        translate([detector_x, 0, z_front_lens - 0.3]) {
            intersection() {
                scale([1.8, 1, 0.6]) sphere(d = 5.5);
                translate([-6, -3, 0]) cube([12, 6, 2]);
            }
        }
    }
}

module pwb_and_connector() {
    // PWB (Phenol paper circuit board)
    color(col_pwb) {
        difference() {
            translate([-body_w/2, body_h/2 - pwb_total_h, z_pwb_back])
                cube([body_w, pwb_total_h, 1.2]);
            
            // Cutouts matching body/mounting if needed
            translate([-hole_pitch/2, 0, z_pwb_back - 0.5])
                cylinder(d = hole_dia, h = 2.2);
            translate([hole_pitch/2, 0, z_pwb_back - 0.5])
                cylinder(d = hole_dia, h = 2.2);
        }
    }

    // 3-Pin JST/JCTC connector
    color(col_conn) {
        // Shrouded connector body pointing downwards (-Y)
        translate([-conn_w/2, conn_bottom_y, z_pwb_back - 3.3])
            cube([conn_w, pwb_drop - (body_h/2 - conn_bottom_y) + 4.6, 4.5]);
    }

    // Connector pins
    color(col_pin) {
        for (i = [-1:1]) {
            translate([i * 1.5, conn_bottom_y - 0.8, z_pwb_back - 1.2])
                cube([0.5, 2.0, 0.5], center = true);
        }
    }
}

// ================= Assembly =================

module gp2y0a21yk0f() {
    main_case();
    lenses();
    pwb_and_connector();
}

gp2y0a21yk0f();