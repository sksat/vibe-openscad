// Mug parameters
body_od = 80;
body_id = 70;
body_h = 90;
wall_t = (body_od - body_id) / 2; // 5mm
bottom_t = 6;

// Handle parameters
handle_hole_h = 30;    // inner opening height
handle_hole_w = 25;    // inner opening width (radial depth from body)
handle_bar_t = 6;      // thickness of the handle cross-section
handle_bar_w = 12;     // width (tangential / Z-perpendicular) of handle bar

// Derived handle dimensions
// The handle attaches on +X side.
// Inner opening starts at body outer radius and extends outward by handle_hole_w.
// Total outer reach = body_od/2 + handle_hole_w + handle_bar_t
handle_outer_r = body_od/2 + handle_hole_w + handle_bar_t;
handle_inner_r_x = body_od/2;  // where inner hole starts (at body surface)

// Handle vertical center at mug mid-height
handle_center_z = body_h / 2;

module mug_body() {
    difference() {
        // Outer cylinder
        cylinder(d = body_od, h = body_h, $fn = 120);
        // Inner cavity
        translate([0, 0, bottom_t])
            cylinder(d = body_id, h = body_h - bottom_t + 1, $fn = 120);
    }
}

module handle() {
    // Build handle as a D-shape on the +X side.
    // The D is: flat side against the mug body, curved side going outward.
    // We'll construct it with hull / minkowski or direct geometry.
    // Approach: create a torus-like shape by sweeping a cross-section
    // along a path that goes: up from bottom attach point, around a
    // semicircle at top, and back down — but simpler: use a rounded
    // rectangular ring and subtract the inner hole.

    // Handle total outer envelope:
    total_h = handle_hole_h + 2 * handle_bar_t;
    total_w = handle_hole_w + handle_bar_t; // from body surface outward

    // We'll create the handle as a 2D cross-section extruded and shaped.
    // Use a simpler approach: a filleted rectangular loop on XZ plane.

    // Spine of the handle (centerline of the bar cross-section):
    // It's a rounded rectangle path on the XZ plane.
    // From body surface: the spine is at handle_bar_t/2 offset inward/outward.

    spine_inner_x = body_od/2 + handle_bar_t/2;
    spine_outer_x = body_od/2 + handle_hole_w + handle_bar_t/2;
    spine_bottom_z = handle_center_z - handle_hole_h/2 - handle_bar_t/2;
    spine_top_z = handle_center_z + handle_hole_h/2 + handle_bar_t/2;

    // Corner radius for the outer corners of the handle path
    corner_r = handle_bar_t/2 + 2;

    // Cross section: an ellipse/circle of handle_bar_t x handle_bar_w
    // We'll use hull of spheres along the spine, or linear_extrude a 2D shape.

    // Simple approach: create solid block, subtract inner hole.
    // Solid handle block (on +X side)
    translate([body_od/2 - 1, -handle_bar_w/2, handle_center_z - (handle_hole_h/2 + handle_bar_t)])
    {
        // Outer solid rounded shape
        difference() {
            // Outer block with rounded outer corners
            minkowski() {
                cube([handle_hole_w + handle_bar_t - corner_r + 1,
                      handle_bar_w - 2*2,
                      handle_hole_h + 2*handle_bar_t - 2*corner_r]);
                translate([0, 0, corner_r])
                    resize([corner_r*2, 2*2, corner_r*2])
                        sphere(r = corner_r, $fn = 40);
            }
            // Inner cutout (the hole for fingers)
            translate([handle_bar_t - 0.5, -1, handle_bar_t])
                cube([handle_hole_w + 2, handle_bar_w + 2, handle_hole_h]);
        }
    }
}

module handle_v2() {
    // More robust approach using 2D profile rotated/extruded
    // Create handle cross-section as a ring on the XZ plane, then
    // linear_extrude in Y with handle_bar_w.

    // 2D outline of the handle (XZ plane cross-section)
    // Outer rounded rect and inner rounded rect
    or_w = handle_hole_w + 2 * handle_bar_t;  // total radial size
    or_h = handle_hole_h + 2 * handle_bar_t;  // total height size
    ir_w = handle_hole_w;
    ir_h = handle_hole_h;
    cr_outer = min(or_w, or_h) * 0.35;  // outer corner radius
    cr_inner = cr_outer * 0.4;

    cx = body_od/2 - handle_bar_t * 0.3;  // X start (overlap with body for union)
    cz = handle_center_z;  // center Z

    translate([0, -handle_bar_w/2, 0])
    rotate([-90, 0, 0])
    linear_extrude(height = handle_bar_w, center = false)
    {
        difference() {
            // Outer shape
            translate([cx, -(or_h/2) + cz])
                offset(r = cr_outer, $fn = 40)
                    offset(delta = -cr_outer)
                        square([or_w, or_h]);
            // Inner cutout
            translate([cx + handle_bar_t, -(ir_h/2) + cz])
                offset(r = cr_inner, $fn = 30)
                    offset(delta = -cr_inner)
                        square([ir_w, ir_h]);
            // Cut the flat side (remove the part that would be inside the body)
            translate([cx - or_w, cz - or_h])
                square([or_w, or_h * 2]);
        }
    }
}

// Final assembly
union() {
    mug_body();
    handle_v2();
}