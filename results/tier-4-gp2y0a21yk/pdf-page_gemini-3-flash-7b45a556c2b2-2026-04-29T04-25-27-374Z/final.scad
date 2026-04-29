// Sharp GP2Y0A21YK0F Distance Measuring Sensor
// Units: mm
// Origin: Center of the main body (29.5 x 13 x 11.5 block)
// +Z: Up (toward lenses), +Y: Forward

$fn = 32;

// Dimensions
BODY_W = 29.5;
BODY_D = 13;
BODY_H = 11.5; // Main case + flange thickness

FLANGE_W = 37; // Distance between ear arc centers
FLANGE_R = 3.75;
FLANGE_T = 1.5; // Estimated from "2-1.5" note

LENS_PROTRUSION = 2;
LENS_H = 7.2; // From front view height
EMITTER_W = 7.5;
DETECTOR_W = 16.3;
LENS_DIST = 20;
LENS_OFFSET_X = -10.25; // Calculated: -14.75 (left edge) + 4.5

CONN_W = 10.1;
CONN_OFFSET_RIGHT = 14.75;
CONN_X_MAX = (FLANGE_W/2 + FLANGE_R) - CONN_OFFSET_RIGHT; // 18.5 + 3.75 - 14.75 = 7.5
CONN_X_MIN = CONN_X_MAX - CONN_W; // 7.5 - 10.1 = -2.6

module gp2y0a21yk0f() {
    // 1. Main Case Body (centered at origin)
    color("DimGray")
    cube([BODY_W, BODY_D, BODY_H], center=true);

    // 2. Connecting Bar (Flange) with Mounting Ears
    color("DimGray")
    difference() {
        union() {
            // Main plate
            translate([0, 0, -BODY_H/2 + FLANGE_T/2])
                cube([FLANGE_W, BODY_D, FLANGE_T], center=true);
            
            // Rounded Ears
            for(x = [-FLANGE_W/2, FLANGE_W/2]) {
                translate([x, 0, -BODY_H/2 + FLANGE_T/2])
                    cylinder(h=FLANGE_T, r=FLANGE_R, center=true);
            }
        }
        
        // Mounting Holes
        for(x = [-FLANGE_W/2, FLANGE_W/2]) {
            translate([x, 0, -BODY_H/2])
                cylinder(d=3.2, h=FLANGE_T*3, center=true);
        }
        
        // Cable Cutout
        translate([(CONN_X_MIN + CONN_X_MAX)/2, -BODY_D/2, -BODY_H/2])
            cube([CONN_W, BODY_D/2, FLANGE_T*3], center=true);
    }

    // 3. Lenses (Top protrusions)
    color("Black") {
        // Light Emitter (Circular protrusion)
        translate([LENS_OFFSET_X, 0, BODY_H/2])
            hull() {
                translate([0, (7.2-EMITTER_W)/2, 0]) cylinder(d=EMITTER_W, h=LENS_PROTRUSION);
                translate([0, -(7.2-EMITTER_W)/2, 0]) cylinder(d=EMITTER_W, h=LENS_PROTRUSION);
            }

        // Light Detector (Rectangular/Oval protrusion)
        translate([LENS_OFFSET_X + LENS_DIST, 0, BODY_H/2])
            hull() {
                translate([(DETECTOR_W-7.2)/2, 0, 0]) cylinder(d=7.2, h=LENS_PROTRUSION);
                translate([-(DETECTOR_W-7.2)/2, 0, 0]) cylinder(d=7.2, h=LENS_PROTRUSION);
            }
    }

    // 4. Connector (Simplified block sticking out from bottom/side)
    color("White") {
        translate([(CONN_X_MIN + CONN_X_MAX)/2, -BODY_D/2 - 2.5, -BODY_H/2 - 1.5])
            cube([CONN_W, 5, 8], center=true);
    }

    // 5. Cable (Simplified representation)
    color("Gray") {
        translate([(CONN_X_MIN + CONN_X_MAX)/2, -BODY_D/2 - 5, -BODY_H/2 - 2])
            rotate([90, 0, 0])
                cylinder(d=3, h=20);
    }
}

// Render the model
gp2y0a21yk0f();