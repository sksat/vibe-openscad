// Sharp GP2Y0D413K0F Distance Sensor Model
// Coordinate system: Center of main body is origin [0,0,0]
// +Z is Up, -Z is Down (Connector points down)
// +Y is Front (Lenses point front)
// +X is Right (from front view)

$fn = 32;

// Colors
color_case = [0.15, 0.15, 0.15];       // Carbonic ABS (Dark Slate Gray/Black)
color_lens = [0.2, 0.0, 0.1, 0.9];       // Acrylic visible light cut-off resin (Dark Red/Purple)
color_pwb = [0.7, 0.45, 0.2];           // Paper phenol (Brown/Beige)
color_connector = [0.9, 0.9, 0.9];     // White plastic housing
color_pin = [0.8, 0.8, 0.3];           // Gold/Brass pins

// Main Body Case Dimensions
case_w = 29.45;
case_d = 7.1;
case_h = 13.05;

// PWB Dimensions
pwb_w = 29.45;
pwb_d = 1.2;
pwb_h = 13.5;
pwb_z_offset = 6.525 - pwb_h/2; // Top of PWB aligns with top of body (Z = 13.05/2)

// Lens Cases Dimensions
lens_case_h = 8.4;
lens_case_d = 6.3;

// Left Lens Case (Light Emitter)
lens_case_l_w = 7.5;
lens_case_l_x = -10.225; // Center calculated from -14.725 (left edge) + 0.75 (gap) + 7.5/2

// Right Lens Case (Light Detector)
lens_case_r_w = 16.3;
lens_case_r_x = 5.825;   // Center calculated from -2.325 (start) + 16.3/2

// Connector (JCTC 12001W90-3P-HF) Dimensions
conn_w = 10.1;
conn_d = 4.5; // From PWB front to connector back
conn_h = 7.0;
conn_x = -5.925; // Left aligned: left edge of body (-14.725) + 3.75 + 10.1/2
conn_y = -3.55 - pwb_d - 3.3 + conn_d/2; // Based on 3.3mm projection from PWB back
conn_z = -12.375 + conn_h/2; // Bottom-most point is Z = -12.375 (18.9mm below top)

union() {
    // --- 1. Main Body Case (Carbonic ABS) ---
    color(color_case) {
        cube([case_w, case_d, case_h], center=true);
    }

    // --- 2. Lens Cases (Carbonic ABS, projecting front +Y) ---
    color(color_case) {
        // Left Lens Case (Emitter)
        translate([lens_case_l_x, case_d/2 + lens_case_d/2, 0])
            cube([lens_case_l_w, lens_case_d, lens_case_h], center=true);
        
        // Right Lens Case (Detector)
        translate([lens_case_r_x, case_d/2 + lens_case_d/2, 0])
            cube([lens_case_r_w, lens_case_d, lens_case_h], center=true);
    }

    // --- 3. Lenses (Acrylic resin, projecting +Y from lens cases) ---
    color(color_lens) {
        // Light Emitter Lens (Circular, Left)
        // Center of lens is at X = -10.225
        translate([-10.225, case_d/2 + lens_case_d, 0])
            rotate([-90, 0, 0])
                cylinder(d=5.5, h=2.0);

        // Light Detector Lens (Rectangular, Right)
        // Center of detector is at X = 9.475 (Emitter center -10.225 + 19.7)
        translate([9.475, case_d/2 + lens_case_d + 1.0, 0])
            cube([6.5, 2.0, 5.0], center=true);
    }

    // --- 4. PWB (Paper phenol, attached to rear -Y) ---
    color(color_pwb) {
        translate([0, -case_d/2 - pwb_d/2, pwb_z_offset])
            cube([pwb_w, pwb_d, pwb_h], center=true);
    }

    // --- 5. Connector Housing & Pins ---
    // Housing (White plastic)
    color(color_connector) {
        translate([conn_x, conn_y, conn_z])
            cube([conn_w, conn_d, conn_h], center=true);
    }
    
    // 3 Pins (Simplified representation, pointing down -Z)
    color(color_pin) {
        for (i = [-1 : 1]) {
            translate([conn_x + i * 2.5, conn_y - 1.0, conn_z - conn_h/2 - 1.0])
                cube([0.6, 0.6, 2.5], center=true);
        }
    }
}