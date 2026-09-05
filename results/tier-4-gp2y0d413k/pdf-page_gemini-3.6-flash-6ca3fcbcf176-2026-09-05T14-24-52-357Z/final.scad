// =================================================================
// Sharp Distance Sensor GP2Y0D413K0F
// Unit: mm
// Origin: Center of main housing body (0,0,0)
// -Z axis: Mounting side (PWB / Connector side)
// +Y axis: Front (Lens side)
// =================================================================

$fn = 40;

// --- Dimensions from Datasheet ---
body_w     = 29.45; // Width (X)
body_d     = 7.1;   // Depth (Y)
body_h     = 13.05; // Height (Z)

emitter_x  = -body_w/2 + 4.5;   // Light emitter position (*4.5 mm from left)
detector_x = emitter_x + 19.7;   // Light detector position (*19.7 mm from emitter)

lens_r     = 3.1;   // Lens radius
lens_prot  = 2.0;   // Lens bezel protrusion depth

pwb_thick  = 1.2;   // PWB thickness
pwb_w      = body_w;
pwb_d      = body_d;

conn_w     = 10.1;  // Connector width
conn_d     = 5.5;   // Connector depth
conn_h     = 3.3;   // Connector height protrusion below PWB

module gp2y0d413k0f() {
    
    // 1. Main Housing (Carbonic ABS - Dark Gray / Black)
    color([0.20, 0.20, 0.22]) {
        difference() {
            union() {
                // Main body block
                cube([body_w, body_d, body_h], center=true);
                
                // Emitter Lens Housing
                translate([emitter_x, body_d/2 + lens_prot/2, 0.8])
                    cube([lens_r*2 + 0.8, lens_prot, lens_r*2 + 0.8], center=true);
                    
                // Detector Lens Housing
                translate([detector_x, body_d/2 + lens_prot/2, 0.8])
                    cube([lens_r*2 + 0.8, lens_prot, lens_r*2 + 0.8], center=true);
            }
            
            // Recess for Emitter Lens
            translate([emitter_x, body_d/2, 0.8])
                rotate([-90, 0, 0])
                cylinder(r=lens_r, h=lens_prot + 1);
                
            // Recess for Detector Lens
            translate([detector_x, body_d/2, 0.8])
                rotate([-90, 0, 0])
                cylinder(r=lens_r, h=lens_prot + 1);
                
            // Bottom notch for Connector
            translate([0, body_d/2 - 1, -body_h/2 + 1.5])
                cube([conn_w + 0.4, body_d, 3], center=true);
        }
    }

    // 2. Lenses (Acrylic Acid Resin - Dark Translucent)
    color([0.10, 0.10, 0.15]) {
        // Emitter Lens (Convex)
        translate([emitter_x, body_d/2 + 0.2, 0.8])
            rotate([-90, 0, 0])
            intersection() {
                cylinder(r=lens_r - 0.1, h=lens_prot + 0.5);
                translate([0, 0, -1]) sphere(r=lens_r + 0.6);
            }

        // Detector Lens (Convex)
        translate([detector_x, body_d/2 + 0.2, 0.8])
            rotate([-90, 0, 0])
            intersection() {
                cylinder(r=lens_r - 0.1, h=lens_prot + 0.5);
                translate([0, 0, -1]) sphere(r=lens_r + 0.6);
            }
    }

    // 3. PWB (Paper Phenol Board)
    color([0.45, 0.35, 0.20]) {
        translate([0, 0, -body_h/2 - pwb_thick/2])
            cube([pwb_w, pwb_d, pwb_thick], center=true);
    }

    // 4. Connector Body (JCTC 12001W90-3P-HF)
    color([0.92, 0.92, 0.88]) {
        translate([0, body_d/2 - conn_d/2, -body_h/2 - pwb_thick - conn_h/2])
            difference() {
                cube([conn_w, conn_d, conn_h], center=true);
                
                // Pin socket cavity
                translate([0, 0.5, -0.5])
                    cube([conn_w - 1.2, conn_d - 1.0, conn_h], center=true);
            }
    }

    // 5. Connector Metal Pins (1: Vo, 2: GND, 3: Vcc)
    color([0.85, 0.75, 0.30]) {
        for (i = [-1:1]) {
            translate([i * 2.0, body_d/2 - conn_d/2, -body_h/2 - pwb_thick - conn_h/2])
                cube([0.5, 0.5, conn_h - 0.5], center=true);
        }
    }

    // 6. Top Marking (SHARP Logo & Model Name)
    color([0.85, 0.85, 0.85]) {
        translate([0, 0, body_h/2 + 0.01])
            linear_extrude(height=0.05) {
                translate([0, 1.0, 0])
                    text("SHARP", size=1.8, halign="center", valign="center", font="Liberation Sans:style=Bold");
                translate([0, -1.8, 0])
                    text("0D413K F", size=1.4, halign="center", valign="center", font="Liberation Sans:style=Bold");
            }
    }
}

// --- Call Module ---
gp2y0d413k0f();