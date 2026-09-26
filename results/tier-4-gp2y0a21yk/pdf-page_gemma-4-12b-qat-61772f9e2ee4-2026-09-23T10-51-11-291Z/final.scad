// Sharp GP2Y0A21YK0F Distance Sensor Modeling
// Coordinates: Origin at body center, Mounting face (Connector side) at -Z.
// Units: mm

$fn = 32;

// --- Dimensions ---
// Main body dimensions
body_w = 29.5;       // Total body width (X)
body_h = 23.5;       // Total body height (Y)
body_l = 29.5;       // Total body length (Z)

// Segment dimensions (from side view)
back_l = 16.3;       // Length of the rear section
mid_l = 4.15;        // Length of the middle step
front_l = body_l - back_l - mid_l; // Remaining length for the front face

// Component dimensions
base_h = 13.5;       // Height of the base part
top_h = body_h - base_h; // Height of the top part
lens_case_w = 6.3;   // Width of the lens housing
lens_case_h = 13.0;  // Height of the lens housing
lens_case_l = 7.5;   // Length of the lens housing protrusion
lens_dist = 20.0;    // Distance between lens centers
conn_w = 14.75;      // Width of the connector
conn_t = 1.2;        // Thickness of the PWB/Connector

// --- Modules ---

module body_segment(w, h, l, z_offset) {
    translate([0, 0, z_offset])
    cube([w, h, l], center=true);
}

module lens_housing(x_pos) {
    // The lens housing sticks out from the front face
    // The front face is at Z = body_l / 2
    translate([x_pos, 0, (body_l / 2) + (lens_case_l / 2)])
    hull() {
        // Main block of the lens housing
        translate([0, 0, 0])
        cube([lens_case_w, lens_case_h, lens_case_l], center=true);
        
        // Rounded front edge (R5.75 is specified in the drawing)
        translate([0, 0, lens_case_l / 2])
        sphere(r = 5.75);
    }
}

module connector() {
    // Connector is at the bottom back corner
    // Width 14.75, Thickness 1.2
    translate([0, -base_h / 2 + (base_h - conn_t) / 2, -(body_l / 2) + (back_l / 2)])
    cube([conn_w, conn_t, back_l], center=true);
}

// --- Assembly ---

// 1. Main Body Construction
// We divide the body into 3 sections along the Z-axis to match the "Outline Dimensions" side view
// Back section (Height = 23.5)
translate([0, 0, -(body_l / 2) + (back_l / 2)])
    body_segment(body_w, body_h, back_l);

// Middle section (Height = 10) - Step down
translate([0, 0, -(body_l / 2) + back_l + (mid_l / 2)])
    body_segment(body_w, top_h, mid_l);

// Front section (Height = 10)
translate([0, 0, (body_l / 2) - (front_l / 2)])
    body_segment(body_w, top_h, front_l);

// 2. Lens Housings
// Distance between centers is 20mm (X = +/- 10)
lens_housing(lens_dist / 2);
lens_housing(-lens_dist / 2);

// 3. Connector
connector();

// 4. Mounting Holes (Reference only, as per φ3.2mm)
// Positioned at the ends of the 37mm total width (approx X = +/- 18.5)
translate([18.5, 0, 0]) cylinder(h=2, d=3.2, center=true);
translate([-18.5, 0, 0]) cylinder(h=2, d=3.2, center=true);

// --- Aesthetics (Optional) ---
%color("LightGray", opacity=0.5) body_segment(body_w, body_h, body_l, 0);