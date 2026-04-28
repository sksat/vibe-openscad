// OpenSCAD Mug with Handle
// Global rendering quality (higher value = smoother curves)
$fn = 64;

// Mug body parameters
mug_outer_radius = 80 / 2; // 40mm
mug_inner_radius = 70 / 2; // 35mm
mug_height = 90;
mug_bottom_thickness = 6;

// Handle parameters
handle_thickness = 10;          // Thickness of the handle material
handle_inner_width = 25;        // Internal width of the finger hole (X direction)
handle_inner_height = 30;       // Internal height of the finger hole (Z direction)

// Calculate handle positioning
handle_z_center = mug_height / 2; // Center of the handle vertically on the mug
handle_y_center = 0;              // Center of the handle horizontally (aligned with mug's Y axis)

module mug_body() {
    difference() {
        // Outer cylinder of the mug
        cylinder(h = mug_height, r = mug_outer_radius);

        // Inner hollow part
        // Lifted by mug_bottom_thickness to create the solid bottom
        translate([0, 0, mug_bottom_thickness])
            cylinder(h = mug_height - mug_bottom_thickness, r = mug_inner_radius);
    }
}

module mug_handle() {
    union() {
        // 1. Vertical connecting bar
        // This bar connects the handle to the mug's outer surface (+X direction).
        // It spans the full height of the D-shaped handle.
        translate([
            mug_outer_radius,                           // Starts at the mug's outer surface (X)
            handle_y_center - handle_thickness / 2,     // Centered on Y axis
            handle_z_center - (handle_inner_height / 2 + handle_thickness) // Bottom Z of the handle
        ]) {
            cube([
                handle_thickness,                               // X-dimension (depth from mug into handle)
                handle_thickness,                               // Y-dimension (handle's thickness)
                handle_inner_height + 2 * handle_thickness      // Z-dimension (total height of the handle)
            ]);
        }

        // 2. Top horizontal bar
        // This bar forms the top part of the D-shape.
        translate([
            mug_outer_radius + handle_thickness,        // Starts after the vertical connecting bar (X)
            handle_y_center - handle_thickness / 2,     // Centered on Y axis
            handle_z_center + handle_inner_height / 2   // Top Z of the finger hole
        ]) {
            cube([
                handle_inner_width,                     // X-dimension (width of the finger hole part)
                handle_thickness,                       // Y-dimension (handle's thickness)
                handle_thickness                        // Z-dimension (height of this bar)
            ]);
        }

        // 3. Bottom horizontal bar
        // This bar forms the bottom part of the D-shape.
        translate([
            mug_outer_radius + handle_thickness,        // Starts after the vertical connecting bar (X)
            handle_y_center - handle_thickness / 2,     // Centered on Y axis
            handle_z_center - handle_inner_height / 2 - handle_thickness // Bottom Z of the finger hole
        ]) {
            cube([
                handle_inner_width,                     // X-dimension (width of the finger hole part)
                handle_thickness,                       // Y-dimension (handle's thickness)
                handle_thickness                        // Z-dimension (height of this bar)
            ]);
        }

        // 4. Outer D-shape arc
        // This creates the curved part of the D-shape handle.
        // It's formed by differencing two concentric cylinders and then cutting one half.
        outer_arc_radius = handle_inner_height / 2 + handle_thickness; // Radius of the outer curve
        inner_arc_radius = handle_inner_height / 2;                   // Radius of the inner cut for the arc

        arc_x_position = mug_outer_radius + handle_thickness + handle_inner_width; // X position of the arc's center
        arc_z_position = handle_z_center;                                          // Z position of the arc's center

        translate([arc_x_position, handle_y_center, arc_z_position])
        rotate([90, 0, 0]) { // Rotate so the cylinder's height is along Y, and the arc is in the XZ plane
            difference() {
                // Outer cylinder that defines the overall arc shape
                cylinder(r = outer_arc_radius, h = handle_thickness, center = true);
                
                // Inner cylinder to cut out the inside of the arc, creating a ring shape
                // Use a slightly larger height to ensure a clean cut through the entire handle_thickness
                cylinder(r = inner_arc_radius, h = handle_thickness * 1.01, center = true);
                
                // Cutting cube to remove the left half of the ring, forming the D-shape arc.
                // The cylinders are centered at [0,0,0] in this rotated coordinate system.
                // We want to keep the positive X half (right side), so we cut the negative X half (left side).
                translate([-(outer_arc_radius + 0.1), 0, 0]) // Position cutting cube to completely cover the negative X half
                    cube([outer_arc_radius + 0.2, handle_thickness * 1.01, outer_arc_radius * 2 + 0.2], center=true);
            }
        }
    }
}

// Assemble the complete mug by combining the body and the handle
union() {
    mug_body();
    mug_handle();
}