// Sharp GP2Y0A21YK0F Distance Measuring Sensor
// Units: mm
// Origin: Center of main sensor body
// Axes: +X = Right, +Y = Forward (Lens direction), +Z = Up

$fn = 32;

// Main Dimensions from Datasheet
body_w = 27.95;     // 7.5 + 4.15 + 16.3 mm
body_h = 13.5;      // Height of main body
body_d = 6.3;       // Case depth

flange_w = 37.0;    // Total width including mounting ears
flange_h = 1.6;     // Thickness of mounting bar
flange_d = 7.5;     // Depth of mounting bar (2 * R3.75)
hole_dist = 29.5;   // Distance between mounting holes
hole_dia = 3.2;     // Diameter of mounting holes

// Lens position relative to center
// Left hole at X = -14.75, Emitter center = -14.75 + 4.5 = -10.25
// Detector center = -10.25 + 20.0 = +9.75
emitter_x = -10.25;
detector_x = 9.75;

module gp2y0a21yk0f() {
    union() {
        // --- Main Lens Case Body ---
        difference() {
            // Main case block
            translate([0, 0, 0])
                cube([body_w, body_d, body_h], center=true);
            
            // Top/Front divider notch between emitter and detector
            translate([emitter_x + 7.5/2 + 4.15/2, body_d/4 + 0.1, body_h/4])
                cube([4.15, body_d/2 + 0.2, body_h/2 + 0.2], center=true);
            
            // Lens window recessed cutouts on front (+Y)
            translate([emitter_x, body_d/2 - 0.5, 1.5])
                rotate([-90, 0, 0])
                    cylinder(d=6.8, h=2, center=true);

            translate([detector_x, body_d/2 - 0.5, 1.5])
                rotate([-90, 0, 0])
                    hull() {
                        translate([-2.5, 0, 0]) cylinder(d=6.2, h=2, center=true);
                        translate([ 2.5, 0, 0]) cylinder(d=6.2, h=2, center=true);
                    }
        }

        // --- Lenses (Protruding +Y by 2mm) ---
        // Light Emitter Lens (Circular)
        translate([emitter_x, body_d/2 + 1.0, 1.5])
            rotate([-90, 0, 0])
                cylinder(d=6.0, h=2.0, center=true);

        // Light Detector Lens (Oval / Dual-convex)
        translate([detector_x, body_d/2 + 1.0, 1.5])
            rotate([-90, 0, 0])
                hull() {
                    translate([-2.5, 0, 0]) cylinder(d=5.5, h=2.0, center=true);
                    translate([ 2.5, 0, 0]) cylinder(d=5.5, h=2.0, center=true);
                }

        // --- Mounting Flange Bar ---
        translate([0, 0, -body_h/2 + flange_h/2]) {
            difference() {
                // Flange outer shape
                hull() {
                    translate([-hole_dist/2, 0, 0])
                        cylinder(d=flange_d, h=flange_h, center=true);
                    translate([hole_dist/2, 0, 0])
                        cylinder(d=flange_d, h=flange_h, center=true);
                }
                
                // Two Mounting Holes (dia 3.2mm)
                translate([-hole_dist/2, 0, 0])
                    cylinder(d=hole_dia, h=flange_h + 1, center=true);
                translate([hole_dist/2, 0, 0])
                    cylinder(d=hole_dia, h=flange_h + 1, center=true);
                
                // Cable cutout notch
                translate([0, -flange_d/4, 0])
                    cube([10.1, flange_d/2 + 0.1, flange_h + 1], center=true);
            }
        }

        // --- Lower Connector Shroud & PCB ---
        translate([0, -0.5, -body_h/2 - 2.5]) {
            difference() {
                cube([10.1, 5.0, 5.0], center=true);
                translate([0, 0, -1])
                    cube([8.5, 3.8, 4.0], center=true);
            }
        }

        // --- Cable Wire Bundle Representation ---
        translate([0, -1.0, -body_h/2 - 7.0]) {
            rotate([90, 0, 0])
                cylinder(d=3.2, h=8.0, center=true);
        }
    }
}

gp2y0a21yk0f();