// Mug parameters
outer_r = 80 / 2;   // 40mm
inner_r = 70 / 2;   // 35mm
mug_h = 90;
bottom_t = 6;

// Handle parameters
handle_inner_h = 30;
handle_inner_w = 25;
handle_bar_r = 5;       // cross-section radius of the handle bar
handle_center_z = mug_h / 2;  // vertical center of handle

// Derived
handle_outer_h = handle_inner_h + 2 * handle_bar_r;
handle_outer_w = handle_inner_w + 2 * handle_bar_r;

$fn = 80;

module mug_body() {
    difference() {
        // Outer cylinder
        cylinder(r = outer_r, h = mug_h);
        // Inner cavity
        translate([0, 0, bottom_t])
            cylinder(r = inner_r, h = mug_h - bottom_t + 1);
    }
}

// D-shaped handle: a rounded rectangular ring on the +X side
// We build it as a torus-like sweep of a circle along a D-shaped path
module handle() {
    // The handle path (in the XZ plane, centered at the mug center height):
    // - Two vertical straight segments at x = outer_r (against the mug wall)
    //   from z_bottom to z_top
    // - A semicircular arc on the outside connecting top and bottom
    
    half_h = handle_inner_h / 2;
    ext = handle_inner_w;  // how far the handle extends from the mug surface
    
    // We'll use hull-based approach with spheres along the path
    // Path points for the D shape (in XZ plane, Y=0)
    // Start at bottom attachment, go out in a semicircle, come back to top attachment
    
    attach_x = outer_r;
    z_bot = handle_center_z - half_h;
    z_top = handle_center_z + half_h;
    
    // Straight segments (left side of D, against mug)
    // Bottom straight to bottom-outer corner
    // Semicircle from bottom-outer around to top-outer
    // Top-outer back to top attachment
    
    // We'll define the D path as a series of points and sweep
    // Using polyhedron is complex; instead use minkowski or hull chains
    
    // Simpler approach: build handle from hulled spheres along path
    
    n_arc = 20;  // segments for the semicircle
    
    module path_sphere(pos) {
        translate(pos) sphere(r = handle_bar_r);
    }
    
    // Generate path points
    // Bottom attachment point (on mug surface)
    // Bottom-outer corner (rounded)
    // Arc points going from bottom to top on the outside
    // Top-outer corner
    // Top attachment point
    
    // The semicircle center is at (attach_x, 0, handle_center_z)
    // Semicircle radius = half_h in Z, ext in X — actually let's make it
    // a proper semicircle. The D shape: straight vertical at x=attach_x,
    // semicircular bulge outward.
    
    // Semicircle center
    cx = attach_x;
    cz = handle_center_z;
    arc_r_z = half_h;
    arc_r_x = ext;
    
    // Path: from (cx, 0, z_bot) along elliptical arc to (cx, 0, z_top)
    // Parametric: angle from -90 to +90 degrees
    // x = cx + arc_r_x * cos(angle)  ... but at angle=-90 and +90, cos=0 → x=cx
    // z = cz + arc_r_z * sin(angle)
    // That gives us the right side arc from bottom to top
    
    // Actually we want the arc to go outward (+X direction)
    // At angle = -90: (cx + 0, cz - arc_r_z) = bottom attachment ✓
    // At angle = 0: (cx + arc_r_x, cz) = furthest point ✓  
    // At angle = +90: (cx + 0, cz + arc_r_z) = top attachment ✓
    
    points = [for (i = [0:n_arc]) 
        let(angle = -90 + i * 180 / n_arc)
        [cx + arc_r_x * cos(angle), 0, cz + arc_r_z * sin(angle)]
    ];
    
    // Create hull chain along the path
    for (i = [0:len(points)-2]) {
        hull() {
            path_sphere(points[i]);
            path_sphere(points[i+1]);
        }
    }
    
    // Add straight vertical segment connecting top and bottom on the mug side
    hull() {
        path_sphere([cx, 0, z_bot]);
        path_sphere([cx, 0, z_top]);
    }
}

union() {
    mug_body();
    handle();
}