// Mug body parameters
outer_radius = 80 / 2;
inner_radius = 70 / 2;
wall_thickness = outer_radius - inner_radius; // Should be 5mm
height = 90;
bottom_thickness = 6;

// Handle parameters
handle_inner_height = 30;
handle_inner_width = 25;
handle_thickness = wall_thickness; // Same thickness as mug wall

// Calculate handle outer dimensions
handle_outer_radius = handle_inner_width / 2 + handle_thickness;
handle_outer_height = handle_inner_height + 2 * handle_thickness;

// Position handle in the middle of the mug height
handle_z_offset = (height - handle_outer_height) / 2;

module mug_body() {
    difference() {
        // Outer cylinder
        cylinder(h = height, r = outer_radius, $fn = 64);

        // Inner cylinder (for hollow space)
        translate([0, 0, bottom_thickness])
        cylinder(h = height - bottom_thickness, r = inner_radius, $fn = 64);
    }
}

module mug_handle() {
    // Position handle on the +X side of the mug
    // The handle's 'straight' side will be aligned with the mug's outer radius
    translate([outer_radius, 0, handle_z_offset]) {
        difference() {
            // Outer handle shape (rounded rectangle / half-cylinder extrusion)
            linear_extrude(height = handle_outer_height) {
                union() {
                    circle(r = handle_outer_radius, $fn = 32);
                    // Square to connect half-circle to straight edge, ensuring full arc
                    square([handle_outer_radius, 2 * handle_outer_radius], center = false);
                }
            }

            // Inner handle shape (to create the D-shape hole)
            translate([handle_thickness, 0, 0]) // Shift inner shape to the right to create the D
            linear_extrude(height = handle_inner_height) {
                union() {
                    circle(r = handle_inner_width / 2, $fn = 32);
                    square([handle_inner_width / 2, handle_inner_width], center = false);
                }
            }
        }
    }
}

union() {
    mug_body();
    mug_handle();
}