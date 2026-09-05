// Sharp GP2Y0D413K0F Distance Sensor OpenSCAD Model
// Unit: mm
// Coordinate system: Center of the main body is at origin (0,0,0)
// +Z: Up, +Y: Front (Lens direction), +X: Right

$fn = 50;

module gp2y0d413k0f() {
    // Colors
    case_color = [0.15, 0.15, 0.15]; // Carbonic ABS (dark gray/black)
    lens_color = [0.1, 0.1, 0.1, 0.8]; // Acrylic acid resin (dark/visible light cut)
    pwb_color = [0.3, 0.2, 0.1]; // Paper phenol (brownish)
    pin_color = [0.8, 0.7, 0.2]; // Gold/brass pins
    
    // Main Body Dimensions (estimated from drawing: width=29.45, height=13.5, depth around 9-10)
    body_w = 29.45;
    body_h = 13.5;
    body_d = 9.0; // estimated total thickness excluding lens case and connector

    // 1. Main Body Case
    color(case_color)
    translate([-body_w/2, -body_d/2, -body_h/2])
    cube([body_w, body_d, body_h]);

    // 2. Lens Case (Front protrusion)
    // Front protrudes by 7.1mm (7.1±0.1) from front face
    lens_case_w = 29.45;
    lens_case_h = 13.05;
    lens_case_d = 7.1;
    
    color(case_color)
    translate([-lens_case_w/2, 0, -lens_case_h/2])
    cube([lens_case_w, lens_case_d, lens_case_h]);

    // 3. Lenses
    // Left: Light emitter (circular window), Center is at X = -body_w/2 + 4.5 = -29.45/2 + 4.5 = -10.225
    // Right: Light detector (rectangular window), Center is at X = -body_w/2 + 19.7 = -29.45/2 + 19.7 = 4.975
    // The drawing shows lenses on the front face of the lens case (Y = lens_case_d)
    
    // Emitter Lens (Circular, approx diameter based on 8.4/7.2 height scale -> ~6mm)
    color(lens_color)
    translate([-10.225, lens_case_d + 0.01, 0])
    rotate([90, 0, 0])
    cylinder(h=0.5, d=6.0);

    // Detector Lens (Rectangular, 7.2 height, width approx 6mm)
    color(lens_color)
    translate([4.975 - 3.0, lens_case_d + 0.01, -3.6])
    cube([6.0, 0.5, 7.2]);

    // 4. PWB (Printed Wire Board) at the bottom
    // Thickness: 1.2, extends from bottom of the body
    pwb_w = 29.45;
    pwb_h = 1.2;
    pwb_d = 6.3; // depth estimation based on drawings
    
    color(pwb_color)
    translate([-pwb_w/2, -pwb_d/2, -body_h/2 - pwb_h])
    cube([pwb_w, pwb_d, pwb_h]);

    // 5. Bottom 3-pin Connector (JCTC 12001W90-3P-HF)
    // Width is 10.1 mm, located centrally at the bottom back
    conn_w = 10.1;
    conn_h = 5.0; // height hanging below
    conn_d = 4.0;
    
    color(case_color)
    translate([-conn_w/2, -conn_d/2 - 1.0, -body_h/2 - pwb_h - conn_h])
    cube([conn_w, conn_d, conn_h]);

    // Pins (3 pins, spaced evenly within 10.1mm width, e.g., pitch ~2.54 or similar)
    pin_pitch = 2.54;
    for (i = [-1, 0, 1]) {
        color(pin_color)
        translate([i * pin_pitch, -2.0, -body_h/2 - pwb_h - conn_h - 2.0])
        cube([0.6, 0.6, 4.0]);
    }
}

// Render the sensor centered at origin
gp2y0d413k0f();