// Sharp GP2Y0A21YK0F Distance Sensor Model
// Units: mm

// --- Parameters ---
body_width = 29.5;
total_width = 37.0;
body_depth = 13.0; // Estimated from side view
total_height = 13.5;
pwb_thickness = 1.2;
hole_dist = 20.0;
hole_dia = 3.2;
lens_case_width = 6.3;
lens_dist = 12.0; // Estimated distance between lens centers
connector_width = 10.1;

// Coordinate adjustment: Center of the body is origin
// Z-axis: PWB surface is at -total_height/2
z_offset = total_height / 2;

module gp2y0a21yk0f() {
    difference() {
        union() {
            // Main Body Case
            translate([0, 0, z_offset - (total_height - pwb_thickness)/2])
                cube([body_width, body_depth, total_height - pwb_thickness], center=true);
            
            // Mounting Ears (Tabs)
            translate([-(total_width/2 - (total_width-body_width)/4), 0, z_offset - (total_height - pwb_thickness)/2])
                cube([(total_width - body_width)/2, body_depth, total_height - pwb_thickness], center=true);
            
            translate([(total_width/2 - (total_width-body_width)/4), 0, z_offset - (total_height - pwb_thickness)/2])
                cube([(total_width - body_width)/2, body_depth, total_height - pwb_thickness], center=true);
            
            // PWB (Base Plate)
            translate([0, 0, -z_offset + pwb_thickness/2])
                cube([total_width, body_depth, pwb_thickness], center=true);
                
            // Lens Cases (Protrusions at the front)
            // Based on top view, lenses are placed symmetrically
            translate([lens_dist/2, body_depth/2 - 3.15, z_offset - (total_height - pwb_thickness)/2 + 2])
                cube([lens_case_width, 6.3, 8.0], center=true);
                
            translate([-lens_dist/2, body_depth/2 - 3.15, z_offset - (total_height - pwb_thickness)/2 + 2])
                cube([lens_case_width, 6.3, 8.0], center=true);
            
            // Connector (simplified)
            translate([0, -body_depth/2, -z_offset - 1.0])
                cube([connector_width, 4.0, 2.0], center=true);
        }
        
        // Mounting Holes
        translate([hole_dist/2, 0, 0])
            rotate([90, 0, 0])
                cylinder(d=hole_dia, h=total_width, center=true, $fn=20);
                
        translate([-hole_dist/2, 0, 0])
            rotate([90, 0, 0])
                cylinder(d=hole_dia, h=total_width, center=true, $fn=20);
    }
}

// Execute modeling
gp2y0a21yk0f();

// Reference markers (optional, for verification)
%translate([0,0,-z_offset]) cube([total_width, body_depth, 0.1], center=true); // Mounting Plane