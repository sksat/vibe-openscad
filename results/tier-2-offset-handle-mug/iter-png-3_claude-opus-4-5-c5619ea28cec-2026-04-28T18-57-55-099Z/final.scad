// Mug parameters
outer_diameter = 80;
inner_diameter = 70;
mug_height = 90;
bottom_thickness = 6;
wall_thickness = 5;

// Handle parameters
handle_inner_height = 30;
handle_inner_width = 25;
handle_thickness = 12;

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
    // Handle creates a D-shape attached to +X side of mug
    // Inner space: 30mm height x 25mm width
    
    handle_tube_r = handle_thickness / 2;
    
    // Vertical positions for top and bottom of handle inner space
    top_z = handle_center_z + handle_inner_height / 2;
    bottom_z = handle_center_z - handle_inner_height / 2;
    
    // Horizontal extension from mug surface
    extend_x = handle_inner_width;
    
    hull() {
        // Top connection point - embedded in mug wall
        translate([outer_radius - handle_tube_r, 0, top_z])
            sphere(r = handle_tube_r, $fn = 40);
        // Top outer point
        translate([outer_radius + extend_x, 0, top_z])
            sphere(r = handle_tube_r, $fn = 40);
    }
    
    hull() {
        // Bottom connection point - embedded in mug wall
        translate([outer_radius - handle_tube_r, 0, bottom_z])
            sphere(r = handle_tube_r, $fn = 40);
        // Bottom outer point
        translate([outer_radius + extend_x, 0, bottom_z])
            sphere(r = handle_tube_r, $fn = 40);
    }
    
    // Outer vertical curved section (semicircle in XZ plane)
    translate([outer_radius + extend_x, 0, handle_center_z])
        rotate([90, 0, 0])
            rotate_extrude(angle = 180, convexity = 10, $fn = 60)
                translate([handle_inner_height / 2, 0, 0])
                    circle(r = handle_tube_r, $fn = 40);
    
    // Connection reinforcement blocks to ensure solid union with mug body
    // Top connection block
    translate([outer_radius - wall_thickness, -handle_tube_r, top_z - handle_tube_r])
        cube([wall_thickness + 2, handle_tube_r * 2, handle_tube_r * 2]);
    
    // Bottom connection block
    translate([outer_radius - wall_thickness, -handle_tube_r, bottom_z - handle_tube_r])
        cube([wall_thickness + 2, handle_tube_r * 2, handle_tube_r * 2]);
}

// Final mug assembly
union() {
    mug_body();
    handle();
}