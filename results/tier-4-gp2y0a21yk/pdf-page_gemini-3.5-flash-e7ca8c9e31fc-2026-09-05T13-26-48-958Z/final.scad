// Sharp GP2Y0A21YK0F Distance Measuring Sensor Model
// Coordinate System: Units in mm, Origin (0,0,0) at the center of the main body.

$fn = 40;

// Dimensions
case_w = 29.5;
case_h = 13.0;
case_d = 6.7;

flange_thickness = 1.5;
hole_dist = 37.0;
hole_r = 3.2 / 2;
flange_r = 3.75;

// Render assembly
main_case();
flanges();
pwb();
lenses();
connector();

// 1. Main Case Body
module main_case() {
    color("dimgray") {
        cube([case_w, case_h, case_d], center=true);
    }
}

// 2. Mounting Flanges (Left & Right Ears with Holes)
module flanges() {
    color("dimgray") {
        difference() {
            union() {
                // Left flange transition & ear
                hull() {
                    translate([-case_w/2, 0, -case_d/2 + flange_thickness/2])
                        cube([0.1, flange_r * 2, flange_thickness], center=true);
                    translate([-hole_dist/2, 0, -case_d/2 + flange_thickness/2])
                        cylinder(h=flange_thickness, r=flange_r, center=true);
                }
                // Right flange transition & ear
                hull() {
                    translate([case_w/2, 0, -case_d/2 + flange_thickness/2])
                        cube([0.1, flange_r * 2, flange_thickness], center=true);
                    translate([hole_dist/2, 0, -case_d/2 + flange_thickness/2])
                        cylinder(h=flange_thickness, r=flange_r, center=true);
                }
            }
            // Left screw hole
            translate([-hole_dist/2, 0, -case_d/2])
                cylinder(h=flange_thickness + 2, r=hole_r, center=true);
            // Right screw hole
            translate([hole_dist/2, 0, -case_d/2])
                cylinder(h=flange_thickness + 2, r=hole_r, center=true);
        }
    }
}

// 3. PWB (Printed Wiring Board) on the back
module pwb() {
    color("sienna") { // Paper phenol brown
        translate([0, 0, -case_d/2 - 1.2/2])
            cube([case_w, case_h, 1.2], center=true);
    }
}

// 4. Emitter and Detector Lens Cases
module lenses() {
    // Light emitter (Left side, round lens case)
    emitter_x = -14.0; // Center relative to origin
    color("dimgray") {
        translate([emitter_x, 0, case_d/2]) {
            // Tapered base (6.3mm total height, 4.3mm base)
            cylinder(h=4.3, d1=8.4, d2=7.2);
            // Tip (2.0mm height)
            translate([0, 0, 4.3])
                cylinder(h=2.0, d=7.2);
        }
    }
    // Emitter Lens (Inside)
    color("cyan", 0.5) {
        translate([emitter_x, 0, case_d/2 + 4.3])
            cylinder(h=1.9, d=5.5);
    }

    // Light detector (Right side, elongated lens case)
    detector_x = 6.0; // Center relative to origin
    color("dimgray") {
        translate([detector_x, 0, case_d/2]) {
            // Tapered base (from width 12.0/height 8.4 to width 11.0/height 7.2)
            hull() {
                // At z=0
                translate([-1.8, 0, 0]) cylinder(h=0.1, r=4.2);
                translate([ 1.8, 0, 0]) cylinder(h=0.1, r=4.2);
                // At z=4.3
                translate([-1.9, 0, 4.3]) cylinder(h=0.1, r=3.6);
                translate([ 1.9, 0, 4.3]) cylinder(h=0.1, r=3.6);
            }
            // Tip (z=4.3 to 6.3)
            hull() {
                translate([-1.9, 0, 4.3]) cylinder(h=2.0, r=3.6);
                translate([ 1.9, 0, 4.3]) cylinder(h=2.0, r=3.6);
            }
        }
    }
    // Detector Lens (Inside)
    color("cyan", 0.5) {
        translate([detector_x, 0, case_d/2 + 4.3]) {
            hull() {
                translate([-1.5, 0, 0]) cylinder(h=1.9, r=2.5);
                translate([ 1.5, 0, 0]) cylinder(h=1.9, r=2.5);
            }
        }
    }
}

// 5. Connector (Bottom side)
module connector() {
    // Width: 10.1mm, Positioned offset to the left.
    // X center = -1.3 (span from -6.35 to 3.75)
    color("white") {
        difference() {
            // Connector housing
            translate([-1.3, -case_h/2 - 3.0, -4.55 + 2.9])
                cube([10.1, 6.0, 5.8], center=true);

            // Slot for pins
            translate([-1.3, -case_h/2 - 4.5, -4.55 + 2.9])
                cube([8.5, 3.5, 4.2], center=true);
        }
    }
    // 3 Pin contacts
    color("gold") {
        for (x = [-1.3 - 2.54, -1.3, -1.3 + 2.54]) {
            translate([x, -case_h/2 - 4.5, -4.55 + 2.9])
                rotate([90, 0, 0])
                    cylinder(h=3.0, d=0.6, center=true);
        }
    }
}