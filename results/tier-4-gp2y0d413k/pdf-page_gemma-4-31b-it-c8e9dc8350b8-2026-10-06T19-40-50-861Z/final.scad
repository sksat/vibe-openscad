// Sharp GP2Y0D413K0F Distance Sensor Model
// Units: mm

/* [Dimensions] */
body_width = 29.45;
body_depth = 13.5;
body_height = 18.9;

lens_protrusion = 7.1;
lens_case_width = 29.45;
lens_case_height = 18.9;

// Lens center positions (marked with * in datasheet)
// Emitter center: 4.5mm from left edge
// Distance between centers: 19.7mm
emitter_x = -body_width/2 + 4.5;
detector_x = emitter_x + 19.7;
lens_z = 5.0; // Estimated center height from origin
lens_y = body_depth/2 + lens_protrusion/2;
lens_radius = 2.5; // Approximate radius for visualization

// Connector dimensions
conn_width = 10.1;
conn_depth = 1.2;
conn_height = 2.0;

/* [Rendering] */
$fn = 32;

union() {
    // Main Case Body
    color("LightGray")
    cube([body_width, body_depth, body_height], center=true);

    // Lens Case (Protrusion)
    color("DimGray")
    translate([0, body_depth/2 + lens_protrusion/2, 0])
    cube([lens_case_width, lens_protrusion, lens_case_height], center=true);

    // Lenses (Emitter and Detector)
    color("Black") {
        // Emitter
        translate([emitter_x, lens_y, lens_z])
        rotate([0, 90, 0])
        cylinder(h = lens_protrusion + 1, r = lens_radius, center=true);

        // Detector
        translate([detector_x, lens_y, lens_z])
        rotate([0, 90, 0])
        cylinder(h = lens_protrusion + 1, r = lens_radius, center=true);
    }

    // Connector / PWB Area
    // Positioned at the bottom (-Z)
    color("Green")
    translate([0, -body_depth/2 + conn_depth/2, -body_height/2 - conn_height/2])
    cube([conn_width, conn_depth, conn_height], center=true);
}

// Guide lines for origin and PWB plane (Optional, can be commented out)
%translate([-body_width/2, 0, -body_height/2]) cube([body_width, body_depth, 0.1]);