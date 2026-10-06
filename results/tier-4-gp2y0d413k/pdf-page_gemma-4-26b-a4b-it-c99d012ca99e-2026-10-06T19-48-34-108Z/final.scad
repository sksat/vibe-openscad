// Sharp GP2Y0D413K0F Distance Sensor Modeling
// Units: mm

$fn = 50;

// --- Dimensions from Datasheet ---
total_width = 29.45;
total_height = 13.5;
lens_case_height = 13.05; // From side view
lens_case_depth = 7.1;    // From side view
pwb_depth = 6.3;          // From side view
total_depth = lens_case_depth + pwb_depth;

lens_dist_from_edge = 4.5;
lens_spacing = 19.7;
lens_diameter = 6.0;      // Estimated from visual scale

connector_width = 10.1;
connector_height = 3.0;   // Estimated

// --- Coordinate Transformation ---
// The origin (0,0,0) is the center of the bounding box.
// Z+ is the lens face, Z- is the PWB/Connector side.

module sensor_gp2y0d413k0f() {
    union() {
        // 1. Main Lens Case (Front part)
        // Positioned so the front face is at Z = total_depth / 2
        translate([0, 0, (total_depth / 2) - (lens_case_depth / 2)])
        cube([total_width, lens_case_height, lens_case_depth], center = true);

        // 2. PWB / Base part (Back part)
        // Positioned so the back face is at Z = -total_depth / 2
        translate([0, 0, (-total_depth / 2) + (pwb_depth / 2)])
        cube([connector_width, total_height, pwb_depth], center = true);
        
        // 3. Connector (Added detail at the bottom)
        translate([0, -(total_height/2) + (connector_height/2), -total_depth/2 + 1])
        cube([connector_width, connector_height, 2], center = true);
    }

    // Subtract Lens Holes
    difference() {
        // Dummy object to perform subtraction on the whole assembly
        // (The union above is used for the actual geometry)
        // We use a large cylinder to clear the front face
        translate([0,0,0]) cube([total_width, total_height, total_depth], center=true);
        
        // Left Lens (Light Emitter)
        translate([-(total_width/2) + lens_dist_from_edge, 0, total_depth/2])
        cylinder(h = lens_case_depth + 2, d = lens_diameter, center = false);
        
        // Right Lens (Light Detector)
        translate([-(total_width/2) + lens_dist_from_edge + lens_spacing, 0, total_depth/2])
        cylinder(h = lens_case_depth + 2, d = lens_diameter, center = false);
    }
}

// Note: To correctly use 'difference' with the 'union' above, 
// we must structure the code to subtract from the union.
// Revised structure for OpenSCAD logic:

module final_model() {
    difference() {
        // The body
        union() {
            // Lens Case
            translate([0, 0, (total_depth / 2) - (lens_case_depth / 2)])
            cube([total_width, lens_case_height, lens_case_depth], center = true);

            // PWB/Base
            translate([0, 0, (-total_depth / 2) + (pwb_depth / 2)])
            cube([connector_width, total_height, pwb_depth], center = true);
            
            // Connector protrusion
            translate([0, -(total_height/2) + (connector_height/2), -total_depth/2 + 1])
            cube([connector_width, connector_height, 2], center = true);
        }

        // Subtract Lens Holes
        // Left Lens
        translate([-(total_width/2) + lens_dist_from_edge, 0, total_depth/2 - 0.1])
        cylinder(h = lens_case_depth + 1, d = lens_diameter);
        
        // Right Lens
        translate([-(total_width/2) + lens_dist_from_edge + lens_spacing, 0, total_depth/2 - 0.1])
        cylinder(h = lens_case_depth + 1, d = lens_diameter);
    }
}

// Render the final model
final_model();

// --- Debugging Info ---
// Width:  29.45 mm
// Height: 13.50 mm
// Depth:  13.40 mm