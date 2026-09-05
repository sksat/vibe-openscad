// Sharp GP2Y0A21YK0F Distance Measuring Sensor
// Units: mm
// Origin: Center of main body (X=0, Y=0, Z=0)
// Orientation: Mounting/PWB face towards -Z, Lenses towards +Z

$fn = 40;

// Dimensions based on datasheet
body_w = 29.5;      // Body width (X)
body_h = 13.0;      // Body height (Y)
body_d = 13.5;      // Total depth from PWB back to lens front (Z)
pwb_t  = 1.2;       // PWB thickness

mount_pitch = 37.0; // Distance between mounting hole centers
mount_hole_d = 3.2; // Mounting hole diameter
flange_r = 3.75;    // Mounting ear radius
flange_t = 1.5;     // Mounting flange thickness

lens_pitch = 20.0;  // Center-to-center distance of lenses

// Colors
c_case      = [0.15, 0.15, 0.15];       // Carbonic ABS (Black)
c_lens      = [0.25, 0.05, 0.10, 0.85]; // Visible light cut-off resin (Dark Red/Purple)
c_pwb       = [0.55, 0.38, 0.18];       // Paper phenol board (Brown)
c_connector = [0.92, 0.90, 0.85];       // Connector body (White/Ivory)
c_pin       = [0.85, 0.75, 0.30];       // Connector pins (Gold/Brass)

module gp2y0a21yk0f() {
    z_back = -body_d / 2; // -6.75
    z_front = body_d / 2; // +6.75

    // --- Main Case & Flanges ---
    color(c_case) {
        difference() {
            union() {
                // Main housing body
                translate([-body_w/2, -body_h/2, z_back + pwb_t])
                    cube([body_w, body_h, 7.2 - pwb_t]);

                // Lens stage base (H: 8.4mm, Depth: 6.3mm from front)
                translate([-body_w/2, -8.4/2, z_front - 6.3])
                    cube([body_w, 8.4, 6.3 - 2.0]);

                // Left mounting flange
                translate([-mount_pitch/2, 0, z_back])
                    hull() {
                        cylinder(r=flange_r, h=flange_t);
                        translate([mount_pitch/2 - body_w/2, -body_h/2, 0])
                            cube([0.1, body_h, flange_t]);
                    }

                // Right mounting flange
                translate([mount_pitch/2, 0, z_back])
                    hull() {
                        cylinder(r=flange_r, h=flange_t);
                        translate([-(mount_pitch/2 - body_w/2), -body_h/2, 0])
                            cube([0.1, body_h, flange_t]);
                    }

                // Lens holders/rims (Front 2mm protruding part)
                // Light Emitter holder (Left)
                translate([-lens_pitch/2, 0, z_front - 2.0])
                    hull() {
                        translate([-(7.5/2 - 7.2/2), 0, 0]) cylinder(d=7.2, h=2.0);
                        translate([ (7.5/2 - 7.2/2), 0, 0]) cylinder(d=7.2, h=2.0);
                    }

                // Light Detector holder (Right)
                translate([lens_pitch/2, 0, z_front - 2.0])
                    hull() {
                        translate([-(16.3/2 - 7.2/2), 0, 0]) cylinder(d=7.2, h=2.0);
                        translate([ (16.3/2 - 7.2/2), 0, 0]) cylinder(d=7.2, h=2.0);
                    }
            }

            // Mounting holes
            translate([-mount_pitch/2, 0, z_back - 1])
                cylinder(d=mount_hole_d, h=flange_t + 2);
            translate([mount_pitch/2, 0, z_back - 1])
                cylinder(d=mount_hole_d, h=flange_t + 2);

            // Lens cavities (cutouts for optical lenses)
            translate([-lens_pitch/2, 0, z_front - 2.1])
                cylinder(d=5.5, h=3);
            translate([lens_pitch/2, 0, z_front - 2.1])
                hull() {
                    translate([-(14.0/2 - 5.5/2), 0, 0]) cylinder(d=5.5, h=3);
                    translate([ (14.0/2 - 5.5/2), 0, 0]) cylinder(d=5.5, h=3);
                }
        }
    }

    // --- Optical Lenses ---
    color(c_lens) {
        // Emitter Lens (Circular convex)
        translate([-lens_pitch/2, 0, z_front - 1.2])
            intersection() {
                translate([0, 0, -4.5]) sphere(r=5.5);
                cylinder(d=5.6, h=2);
            }

        // Detector Lens (Elliptical / Elongated convex)
        translate([lens_pitch/2, 0, z_front - 1.2])
            intersection() {
                hull() {
                    translate([-(14.0/2 - 5.5/2), 0, -4.5]) sphere(r=5.5);
                    translate([ (14.0/2 - 5.5/2), 0, -4.5]) sphere(r=5.5);
                }
                hull() {
                    translate([-(14.0/2 - 5.5/2), 0, 0]) cylinder(d=5.6, h=2);
                    translate([ (14.0/2 - 5.5/2), 0, 0]) cylinder(d=5.6, h=2);
                }
            }
    }

    // --- PCB (Paper Phenol) ---
    color(c_pwb) {
        translate([-body_w/2, -body_h/2, z_back])
            cube([body_w, body_h, pwb_t]);
    }

    // --- Connector (JST 3-pin style) ---
    // Connector extends from -Y edge towards -Y and slightly below back face
    conn_w = 10.1;
    conn_h = 5.9;   // Extends 18.9 - 13.0 = 5.9mm downward
    conn_d = 4.5;

    translate([-conn_w/2, -body_h/2 - conn_h, z_back - 2.1]) {
        color(c_connector) {
            difference() {
                cube([conn_w, conn_h, conn_d]);
                // Internal cavity / mating slot
                translate([0.8, -0.1, 0.8])
                    cube([conn_w - 1.6, conn_h - 1.0, conn_d - 1.6]);
            }
        }

        // 3 Connector Pins (1: Vo, 2: GND, 3: Vcc)
        color(c_pin) {
            for (i = [-1, 0, 1]) {
                translate([conn_w/2 + i * 1.5 - 0.25, 1.0, conn_d/2 - 0.25])
                    cube([0.5, conn_h, 0.5]);
            }
        }
    }
}

// Render model
gp2y0a21yk0f();