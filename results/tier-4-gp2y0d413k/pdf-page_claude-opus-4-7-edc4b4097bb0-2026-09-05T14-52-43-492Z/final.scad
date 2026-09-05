// Sharp GP2Y0D413K0F Distance Sensor Model
// Units: mm
// Origin: center of body, mounting face (PWB / connector side) toward -Z

// ===== Dimensions from datasheet =====
// Front view (looking at lens face)
body_width  = 29.45;   // horizontal width
body_height = 13.5;    // vertical height (bottom view shows 13.5)

// Side view
lens_case_height = 13.05;  // height of the main lens case block
total_height     = 18.9;   // overall height including PWB tab
lens_case_depth  = 7.1;    // depth of the lens case (Z direction from PWB)
pwb_thickness    = 1.2;    // PWB thickness
pwb_extra_depth  = 3.3;    // reference depth of connector protrusion area
top_notch_width  = 2;      // small notch on top
top_notch_offset = 6.3;    // from right edge

// Lens positions (from left edge in front view)
lens_left_x   = 4.5;
lens_right_x  = 4.5 + 19.7;  // 24.2
lens_diameter = 7.2;         // approximate lens diameter (from 8.4/7.2 dims)
lens_radius   = lens_diameter / 2;

// Connector (bottom view: 7.5 from left to connector start area, connector width ~4.15+? )
connector_offset_from_left = 7.5;  // to start of connector housing
connector_width  = 8;              // approx 3-pin connector width
connector_depth  = 6;              // Y depth of connector
connector_height = 5;              // Z height of connector below PWB

// PWB extends full width, sits at -Z side
// Lens case sits on +Z side of PWB

// Coordinate mapping:
//   Body center at origin (X,Y centered on lens case front face)
//   -Z is mounting side (PWB + connector)
//   +Z is lens face
//   X: width (29.45)
//   Y: height (13.05 for lens case)

// ===== Colors =====
case_color      = [0.15, 0.15, 0.15];
lens_color      = [0.05, 0.05, 0.08, 0.9];
pwb_color       = [0.85, 0.75, 0.55];
connector_color = [0.95, 0.95, 0.95];
pin_color       = [0.85, 0.75, 0.35];

// ===== Main body (lens case, black ABS) =====
module lens_case() {
    color(case_color)
    translate([-body_width/2, -lens_case_height/2, 0])
        cube([body_width, lens_case_height, lens_case_depth]);
}

// ===== Top notch (small protrusion) =====
// The 2mm wide notch shown at top of side view
module top_feature() {
    color(case_color)
    translate([body_width/2 - top_notch_offset - top_notch_width/2,
               lens_case_height/2 - 0.01,
               0])
        cube([top_notch_width, 1.5, lens_case_depth - 2]);
}

// ===== Lenses =====
module lens(x_from_left) {
    // Lens x measured from left edge of body
    x = -body_width/2 + x_from_left;
    // Recessed lens well + lens
    translate([x, 0, lens_case_depth - 0.5]) {
        // Recess
        color(case_color)
            cylinder(h = 1.0, r = lens_radius + 0.3, $fn = 48);
        // Lens itself
        color(lens_color)
            translate([0, 0, 0.1])
                cylinder(h = 0.6, r = lens_radius, $fn = 48);
    }
}

// ===== PWB (Paper phenol PCB) =====
// PWB is at the bottom (mounting side), extends beyond lens case in -Y
// Total height 18.9, lens case height 13.05, so PWB tab extends 5.85 below
module pwb() {
    pwb_tab_extension = total_height - lens_case_height;  // 5.85
    color(pwb_color)
    translate([-body_width/2,
               -lens_case_height/2 - pwb_tab_extension,
               -pwb_thickness])
        cube([body_width, total_height, pwb_thickness]);
}

// ===== Connector (JCTC 12001W90-3P-HF, 3-pin) =====
module connector() {
    pwb_tab_extension = total_height - lens_case_height;
    // Connector sits on the PWB tab, on the -Z side
    // Bottom view: 7.5mm from left to start, then 4.15 to pin area, 16.3 remaining
    conn_x = -body_width/2 + connector_offset_from_left;
    conn_y = -lens_case_height/2 - pwb_tab_extension + 0.5;
    
    // Connector housing
    color(connector_color)
    translate([conn_x, conn_y, -pwb_thickness - connector_height])
        cube([connector_width, connector_depth - 1, connector_height]);
    
    // Pins visible (3 pins)
    for (i = [0:2]) {
        color(pin_color)
        translate([conn_x + 1.5 + i * 1.5,
                   conn_y + (connector_depth-1)/2,
                   -pwb_thickness - connector_height + 1])
            cube([0.6, 0.6, connector_height - 1], center = false);
    }
}

// ===== Assembly =====
module GP2Y0D413K0F() {
    lens_case();
    top_feature();
    lens(lens_left_x);   // Light emitter (LED)
    lens(lens_right_x);  // Light detector (PSD)
    pwb();
    connector();
}

GP2Y0D413K0F();