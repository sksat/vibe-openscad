$fn = 128;

// Mug parameters
outer_diam = 80;
inner_diam = 70;
outer_r = outer_diam / 2; // 40
inner_r = inner_diam / 2; // 35
mug_height = 90;
bottom_thickness = 6;

// Handle parameters
handle_overlap_into_mug = 1;        // mm overlap into mug outer wall to ensure solid union
handle_inner_width = 25;            // inner opening width (X direction)
handle_inner_height = 30;           // inner opening height (Z direction)
handle_wall_thickness = 8;          // radial thickness of the handle (from inner opening to outer semicircle)
handle_outer_radius = handle_inner_width + handle_wall_thickness; // semicircle outer radius
handle_center_x = outer_r - handle_overlap_into_mug; // X position of flat (D) face (inner flat sits at this x)
handle_extrude_height = 40;         // total vertical size of the handle solid (will be centered on mug mid-height)

// Derived
handle_half_y = handle_outer_radius + 1; // extra margin for 2D rectangle used in intersection

module handle_solid() {
    // Create a right-half (semi) circle (outer shape of the D) and extrude it vertically.
    // The semicircle is centered at (handle_center_x, 0) and only the right half is kept (flat at x = handle_center_x).
    h = handle_outer_radius;
    cx = handle_center_x;
    linear_extrude(height = handle_extrude_height, center = true) 
        intersection() {
            translate([cx, 0]) circle(r = h);
            // half-plane x >= cx implemented as a large rectangle
            polygon(points = [
                [cx, -h - 2],
                [cx + h + 2, -h - 2],
                [cx + h + 2,  h + 2],
                [cx,  h + 2]
            ]);
        }
}

module mug_with_handle() {
    // Build outer solid (mug outer cylinder + handle), then subtract inner cavity and the finger opening cutout.
    difference() {
        // Outer solid: mug outer + handle
        union() {
            // Mug outer cylinder
            translate([0, 0, 0])
                cylinder(r = outer_r, h = mug_height);
            // Handle solid, centered vertically on the mug
            translate([0, 0, mug_height / 2])
                handle_solid();
        }

        // Subtract inner cavity (to make the mug hollow), leaving the specified bottom thickness.
        translate([0, 0, bottom_thickness])
            cylinder(r = inner_r, h = mug_height - bottom_thickness);

        // Subtract the rectangular finger opening (width x height) from the handle.
        // Position: x from handle_center_x to handle_center_x + handle_inner_width (flat face at handle_center_x),
        // y covers the full semicircle extent, z centered at mug mid-height with specified inner height.
        translate([handle_center_x, -handle_half_y, (mug_height / 2) - (handle_inner_height / 2)])
            cube([handle_inner_width, 2 * handle_half_y, handle_inner_height], center = false);
    }
}

// Render the mug with handle (handle only on +X side)
mug_with_handle();