// Sharp Distance Sensor GP2Y0D413K0F
// Unit: mm
// Origin (0,0,0): Center of the main sensor body

$fn = 32;

// Key Dimensions from datasheet
width        = 29.45; // Main body width
height_body  = 13.05; // Lens case height
depth_body   = 6.3;   // Lens case depth

emitter_x    = -width/2 + 4.5;    // 4.5mm from left edge
detector_x   = emitter_x + 19.7;  // 19.7mm pitch from emitter

module gp2y0d413k0f() {
    // Material Colors
    case_color = [0.2, 0.2, 0.2];       // Carbonic ABS (Dark Gray)
    lens_color = [0.15, 0.15, 0.2, 0.8]; // Visible light cut-off resin (Dark Transparent)
    pwb_color  = [0.55, 0.38, 0.18];    // Paper phenol PWB (Brown)
    pin_color  = [0.85, 0.85, 0.85];    // Metal pins

    union() {
        // --- 1. Main Case Body (Carbonic ABS) ---
        color(case_color) {
            // Main rectangular body
            cube([width, depth_body, height_body], center=true);

            // Lens case barrels (Protrusions on front)
            for (x_pos = [emitter_x, detector_x]) {
                translate([x_pos, depth_body/2 + 1.0, 0])
                    rotate([-90, 0, 0])
                        cylinder(d=8.4, h=2.0, center=true);
            }

            // Connector Shroud (Bottom)
            translate([-1.5, 0, -height_body/2 - 1.25])
                cube([10.1, depth_body, 2.5], center=true);
        }

        // --- 2. Lenses (Emitter & Detector) ---
        color(lens_color) {
            for (x_pos = [emitter_x, detector_x]) {
                // Internal lens structure / surface dome
                translate([x_pos, depth_body/2 + 2.0, 0])
                    rotate([-90, 0, 0])
                        scale([1, 1, 0.6])
                            sphere(d=7.2);
            }
        }

        // --- 3. PWB (Printed Wiring Board) ---
        color(pwb_color) {
            translate([0, -depth_body/2 - 0.6, -1.0])
                cube([width - 1.0, 1.2, height_body - 1.0], center=true);
        }

        // --- 4. Connector Pins (3-pin: Vo, GND, Vcc) ---
        color(pin_color) {
            for (i = [-1:1]) {
                translate([-1.5 + i * 1.8, 0, -height_body/2 - 4.0])
                    cube([0.5, 0.4, 3.0], center=true);
            }
        }

        // --- 5. Top Stamp / Text Marking ---
        color([0.9, 0.9, 0.9]) {
            translate([0, 0, height_body/2 + 0.01]) {
                rotate([0, 0, 180]) {
                    linear_extrude(height=0.05) {
                        translate([0, 1.2, 0])
                            text("SHARP", size=1.6, halign="center", valign="center");
                        translate([0, -1.2, 0])
                            text("0D413K F", size=1.3, halign="center", valign="center");
                    }
                }
            }
        }
    }
}

// Render the sensor
gp2y0d413k0f();