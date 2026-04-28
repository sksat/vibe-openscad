// Mug with handle on +X side

// Parameters
outer_r = 40;       // outer radius = 80mm diameter
inner_r = 35;       // inner radius = 70mm diameter
mug_h   = 90;       // mug height
bot_t   = 6;        // bottom thickness

// Handle parameters
// Inner space: height 30mm, width 25mm
// Handle cross-section tube radius
tube_r  = 3.5;      // handle tube cross-section radius (wall thickness ~3.5mm)

// The handle is a D-shape torus arc on +X side
// Center of the D arc is at x = outer_r (on the mug surface)
// The arc spans 180 degrees (semicircle) facing +X
// Handle inner space: 30mm tall, 25mm wide
// So the arc center is at the mug outer surface, and the loop extends outward

h_space_h = 30;     // inner height of handle space
h_space_w = 25;     // inner width of handle space

// The handle loop:
// Two vertical bars connect at y=0 plane (on +X side of mug)
// separated by h_space_h in Z, centered at mug mid-height
// The outer D-curve has radius = h_space_w / 2 + outer connection offset

// Handle center Z position
handle_z = mug_h / 2;

// The handle consists of:
// 1. A swept D-shape path
// We model the handle as a rotate_extrude arc + two connection bars

// Arc radius for the outer D:
// inner space width = 25mm, tube diameter = 2*tube_r = 7mm
// arc center at x = outer_r (mug surface), arc inner radius ≈ h_space_w/2
// arc center offset from mug axis:
arc_cx = outer_r;  // arc center x (at mug outer surface level)
arc_r  = h_space_w / 2 + tube_r;  // radius of arc centerline = 12.5 + 3.5 = 16

// Vertical bar half-height
bar_half = h_space_h / 2 + tube_r;  // = 18.5

module mug_body() {
    difference() {
        // Outer cylinder
        cylinder(r = outer_r, h = mug_h, center = false, $fn = 128);
        // Inner hollow (starts from bottom thickness)
        translate([0, 0, bot_t])
            cylinder(r = inner_r, h = mug_h - bot_t + 0.1, center = false, $fn = 128);
    }
}

module handle() {
    // The handle is on the +X side
    // It consists of:
    //   - Two vertical straight segments (bars) at x=outer_r, y=0,
    //     from z=handle_z-bar_half to z=handle_z+bar_half (but only the tube length)
    //   - A semicircular arc connecting them on the outside
    //   - The bars connect back into the mug body (embedded in mug wall)

    // We build the handle as:
    // A. Semicircular arc (rotate_extrude of 180 deg) at handle Z mid, but this is for
    //    a torus section — we need a 3D path sweep.
    // 
    // Instead, use hull-based approach for robustness:
    // Place spheres along the path and hull them, or use explicit geometry.
    //
    // Approach: 
    //   Top bar: cylinder from mug surface to arc top
    //   Bottom bar: cylinder from mug surface to arc bottom
    //   Outer arc: half torus (rotate_extrude 180 deg of circle translated)
    //   Connection blobs at joints

    // The arc is a half-torus:
    //   - centered at (arc_cx, 0, handle_z)  -- NO, the arc is in the XY plane per Z slice
    //   - Actually we want a half-torus in the XZ plane... 
    //
    // Let me think differently:
    // The D-handle lives in the XZ plane (y≈0 plane, extended in X and Z).
    // The cross-section of the handle tube is a circle of radius tube_r.
    // The path of the handle centerline is:
    //   - Vertical segment: x=outer_r, y=0, z from (handle_z - h_space_h/2) to (handle_z + h_space_h/2)
    //     But this segment is INSIDE the mug wall — the actual visible bars are from x=outer_r outward
    //   Actually the path:
    //   Bottom attachment: (outer_r, 0, handle_z - h_space_h/2)
    //   Top attachment:    (outer_r, 0, handle_z + h_space_h/2)
    //   Outer arc: semicircle of radius arc_r centered at (outer_r, 0) in XY... 
    //   No — centered at (outer_r, 0, handle_z) sweeping in XZ plane

    // The centerline of the handle:
    // Start: (outer_r, 0, handle_z - h_space_h/2)
    // Go to:  semicircle in the XZ plane around center (outer_r, 0, handle_z)
    //         with radius = h_space_h/2, from bottom to top, bulging in +X direction
    // Wait, that would make the arc radius = h_space_h/2 = 15mm, width = 15mm not 25mm

    // Let me redefine:
    // The handle path in the plane y=0:
    //   Bottom point: A = (outer_r, 0, handle_z - h_space_h/2)
    //   Top point:    B = (outer_r, 0, handle_z + h_space_h/2)
    //   The outer arc connects A to B going through +X
    //   Arc center: C = (outer_r, 0, handle_z)
    //   Arc radius in XZ plane: the arc must reach x = outer_r + h_space_w at midpoint
    //   So arc radius = h_space_w = 25mm (from C to the rightmost point)
    //   But then the arc from C to A has length sqrt(h_space_w^2 + (h_space_h/2)^2) ≠ h_space_w
    //   
    //   For a true semicircle: arc_radius = sqrt((h_space_h/2)^2 + h_space_w^2) ... no
    //   
    //   Actually for D-shape: the straight part is the vertical line x=outer_r,
    //   and the curved part is a semicircle.
    //   For semicircle: diameter = h_space_h, so radius = h_space_h/2 = 15
    //   But then width = radius = 15mm, not 25mm.
    //   
    //   To get width=25 with height=30: use an ellipse, or use a larger arc.
    //   Let's use: arc center at (outer_r + h_space_w - arc_rad, 0, handle_z)
    //   where arc_rad is chosen so the arc passes through A and B and extends to x=outer_r+h_space_w
    //   
    //   Simplest: just use a circular arc where:
    //     - the two endpoints are at (outer_r, 0, handle_z ± h_space_h/2)
    //     - the arc bulges to x = outer_r + h_space_w at z = handle_z
    //   
    //   Arc center at (outer_r - d, 0, handle_z) for some d, radius R:
    //     R^2 = d^2 + (h_space_h/2)^2   [passes through endpoints]
    //     R = d + h_space_w              [reaches x = outer_r + h_space_w]
    //   So: (d + h_space_w)^2 = d^2 + (h_space_h/2)^2
    //       d^2 + 2*d*h_space_w + h_space_w^2 = d^2 + (h_space_h/2)^2
    //       2*d*h_space_w = (h_space_h/2)^2 - h_space_w^2
    //       d = ((h_space_h/2)^2 - h_space_w^2) / (2*h_space_w)
    //       d = (225 - 625) / 50 = -400/50 = -8
    //   So d = -8, R = -8 + 25 = 17
    //   Arc center at (outer_r - (-8), 0, handle_z) = (outer_r + 8, 0, handle_z)
    //   Radius = 17mm
    //   Check: distance from center to endpoint = sqrt(8^2 + 15^2) = sqrt(64+225) = sqrt(289) = 17 ✓
    //   Rightmost point: center_x + R = outer_r + 8 + 17 = outer_r + 25 ✓

    arc_center_x = outer_r + 8;
    arc_center_z = handle_z;
    arc_radius = 17;

    // Angle of endpoints from arc center:
    // endpoint is at (outer_r, handle_z ± h_space_h/2) relative to arc center at (outer_r+8, handle_z)
    // vector from arc_center to bottom endpoint: (-8, -15) in (x,z)
    // angle = atan2(-15, -8) ... but we want angle from +X axis in XZ plane
    // angle_bottom = atan2(-(h_space_h/2), -8) measured from +X of arc
    // In standard: angle from +X axis: atan2(z_component, x_component)
    // bottom endpoint relative to arc center: dx = outer_r - arc_center_x = -8, dz = -15
    // angle_bottom (from +X, CCW in XZ) = atan2(-15, -8) ≈ 180+61.9 = -118.1° or 241.9°
    // top endpoint: dx=-8, dz=+15 → angle_top = atan2(15,-8) ≈ 180-61.9 = 118.1°
    // 
    // The arc from bottom to top going through +X (rightmost point at angle=0):
    // from angle_bottom to angle_top going through 0°
    // That's from -118.1° to +118.1° (total arc = 236.2°) ... that's more than semicircle
    // Hmm, let me reconsider.
    
    // Actually the arc should only be the outer curved part (not enclosing the full D).
    // The D shape: straight vertical line on left (at x=outer_r), arc on right.
    // The arc goes from bottom-right to top-right of the straight line, curving outward.
    
    // Let me just build the handle with linear_extrude / hull approach for simplicity.
    
    // SIMPLIFIED APPROACH using hull of cylinders:
    // We'll create the handle cross-section as a tube (hollow) but since we're doing union
    // with the mug, we just need the solid handle shape.
    
    // Build handle as solid D-ring using rotate_extrude trick won't work for D in XZ plane.
    
    // Use polygon + rotate approach:
    // The handle sweep path is in the XZ plane (y=0).
    // Cross section is a circle of radius tube_r.
    // We approximate the handle as a series of hull() segments.
    
    // Let's use N segments for the arc
    N = 32;
    // arc from angle_start to angle_end (in degrees, in XZ plane, 0=+X, 90=+Z)
    a_bottom = atan2(-(h_space_h/2), -8);  // ≈ -118.07°  → let's use 180+atan2(15,8)
    a_top    = atan2( (h_space_h/2), -8);  // ≈  118.07°

    // Going from a_bottom to a_top through 0° (i.e., through +X direction)
    // a_bottom ≈ -118.07, a_top ≈ 118.07
    // sweep from -118.07 to 118.07 through 0 (the short way going via 0)
    
    a_start = atan2(-(h_space_h/2), -(arc_center_x - outer_r));
    a_end   = atan2( (h_space_h/2), -(arc_center_x - outer_r));
    
    // Build the arc as union of hull'd sphere-pairs
    union() {
        // Arc segments
        for (i = [0:N-1]) {
            a1 = a_start + (a_end - a_start) * i / N;
            a2 = a_start + (a_end - a_start) * (i+1) / N;
            x1 = arc_center_x + arc_radius * cos(a1);
            z1 = arc_center_z + arc_radius * sin(a1);
            x2 = arc_center_x + arc_radius * cos(a2);
            z2 = arc_center_z + arc_radius * sin(a2);
            hull() {
                translate([x1, 0, z1]) sphere(r = tube_r, $fn = 16);
                translate([x2, 0, z2]) sphere(r = tube_r, $fn = 16);
            }
        }
        // Bottom vertical bar: from mug axis connection to arc bottom endpoint
        // bottom arc endpoint:
        bot_x = arc_center_x + arc_radius * cos(a_start);
        bot_z = arc_center_z + arc_radius * sin(a_start);
        top_x = arc_center_x + arc_radius * cos(a_end);
        top_z = arc_center_z + arc_radius * sin(a_end);
        // Connect bottom endpoint to mug surface (embed into mug wall)
        hull() {
            translate([bot_x, 0, bot_z]) sphere(r = tube_r, $fn = 16);
            translate([outer_r - tube_r, 0, bot_z]) sphere(r = tube_r, $fn = 16);
        }
        // Connect top endpoint to mug surface
        hull() {
            translate([top_x, 0, top_z]) sphere(r = tube_r, $fn = 16);
            translate([outer_r - tube_r, 0, top_z]) sphere(r = tube_r, $fn = 16);
        }
    }
}

// Main model
union() {
    mug_body();
    handle();
}