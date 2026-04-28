// Mug Parameters
outer_diameter = 80;
inner_diameter = 70;
mug_height = 90;
bottom_thickness = 6;

// Handle Parameters
handle_inner_h = 30; // Height of the opening
handle_inner_w = 25; // Width of the opening
handle_thickness = 8; // Thickness of the handle material

$fn = 100;

union() {
    // Mug Body
    difference() {
        // Outer Cylinder
        cylinder(h = mug_height, d = outer_diameter);
        
        // Inner Hollow
        translate([0, 0, bottom_thickness])
            cylinder(h = mug_height, d = inner_diameter);
    }

    // Handle (Positioned in +X direction)
    translate([outer_diameter / 2 - 2, 0, mug_height / 2]) { // -2 for slight overlap to ensure union
        rotate([90, 0, 90]) {
            difference() {
                // Outer D-shape (Approximated by rounded rectangle)
                hull() {
                    translate([handle_inner_h / 2, 0, 0])
                        cylinder(h = handle_thickness, d = handle_inner_h + (handle_thickness * 2), center = true);
                    translate([-handle_inner_h / 2, 0, 0])
                        cylinder(h = handle_thickness, d = handle_inner_h + (handle_thickness * 2), center = true);
                    // Square part connecting to the body
                    translate([0, -(handle_inner_w + handle_thickness) / 2, 0])
                        cube([handle_inner_h + handle_thickness * 2, 1, handle_thickness], center = true);
                }
                
                // Inner Hollow of D-shape
                hull() {
                    translate([handle_inner_h / 2, 0, 0])
                        cylinder(h = handle_thickness + 2, d = handle_inner_h, center = true);
                    translate([-handle_inner_h / 2, 0, 0])
                        cylinder(h = handle_thickness + 2, d = handle_inner_h, center = true);
                    // Cutout towards the mug wall
                    translate([0, -handle_inner_w, 0])
                        cube([handle_inner_h, handle_inner_w, handle_thickness + 2], center = true);
                }
            }
        }
    }
}