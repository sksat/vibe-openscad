// Mug parameters
outer_diameter = 80;
inner_diameter = 70;
mug_height = 90;
bottom_thickness = 6;
wall_thickness = 5;

// Handle parameters
handle_inner_height = 30;
handle_inner_width = 25;
handle_thickness = 8;

// Derived values
outer_radius = outer_diameter / 2;
inner_radius = inner_diameter / 2;

// Handle position (centered vertically)
handle_center_z = mug_height / 2;

module mug_body() {
    difference() {
        // Outer cylinder
        cylinder(h = mug_height, r = outer_radius, $fn = 100);
        
        // Inner cavity (hollow part for liquid)
        translate([0, 0, bottom_thickness])
            cylinder(h = mug_height - bottom_thickness + 1, r = inner_radius, $fn = 100);
    }
}

module handle() {
    // Handle dimensions
    handle_outer_height = handle_inner_height + 2 * handle_thickness;
    handle_outer_width = handle_inner_width + handle_thickness;
    
    // Position handle on +X side
    handle_x_offset = outer_radius - 2; // Overlap with mug body for solid union
    
    translate([handle_x_offset, 0, handle_center_z - handle_outer_height / 2]) {
        rotate([90, 0, 0]) {
            linear_extrude(height = handle_thickness, center = true) {
                difference() {
                    // Outer D-shape
                    union() {
                        // Rectangular part connecting to mug
                        translate([0, handle_outer_height / 2])
                            square([handle_thickness + 2, handle_outer_height], center = true);
                        
                        // Semi-circular outer part
                        translate([handle_thickness / 2, handle_outer_height / 2])
                            resize([handle_outer_width * 2, handle_outer_height])
                                circle(d = handle_outer_height, $fn = 60);
                    }
                    
                    // Inner cutout (D-shape hole)
                    translate([handle_thickness / 2, handle_outer_height / 2])
                        resize([handle_inner_width * 2, handle_inner_height])
                            circle(d = handle_inner_height, $fn = 60);
                    
                    // Cut off the left side to make D-shape
                    translate([-handle_outer_width - 5, 0])
                        square([handle_outer_width + 5, handle_outer_height + 10]);
                }
            }
        }
    }
}

// Final mug assembly
union() {
    mug_body();
    handle();
}