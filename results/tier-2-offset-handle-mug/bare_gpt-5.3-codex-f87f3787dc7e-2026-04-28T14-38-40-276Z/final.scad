$fn = 128;

// Mug dimensions
outer_d = 80;
inner_d = 70;
mug_h   = 90;
bottom_t = 6;

// Handle target opening (inner void)
handle_void_h = 30;
handle_void_w = 25;

// Handle placement
z_center = mug_h / 2;
z0 = z_center - handle_void_h / 2;

// Derived
r_outer = outer_d / 2;
r_inner = inner_d / 2;

// Build
union() {
    // Mug body (hollow with bottom thickness)
    difference() {
        cylinder(h = mug_h, d = outer_d);
        translate([0, 0, bottom_t])
            cylinder(h = mug_h - bottom_t + 0.01, d = inner_d);
    }

    // Handle on +X side only: D-shape in XZ profile, extruded along Y
    // Inner opening: 25 (X) x 30 (Z)
    // Ring thickness around opening:
    t_radial = 5;   // along X/Z profile
    t_depth  = 10;  // along Y (grip thickness)

    // Place so inner flat side lies on mug outer tangent plane at x = r_outer
    x_inner_flat = r_outer;
    x_outer_flat = x_inner_flat + t_radial;

    // Inner profile center (for semicircle cap)
    xi_c = x_inner_flat + handle_void_w;       // center x of inner semicircle
    zi_c = z_center;

    // Outer profile center
    xo_c = x_outer_flat + handle_void_w + t_radial;
    zo_c = z_center;

    // Depth placement: centered at y=0
    y0 = - (handle_void_h + 0) / 2; // not used directly; keep symmetry intent

    // Construct as outer D minus inner D, then union with mug
    translate([0, 0, 0])
    difference() {
        // Outer D, extruded in Y
        translate([0, -t_depth/2, 0])
        rotate([-90, 0, 0])
        linear_extrude(height = t_depth)
        polygon(points = concat(
            [[x_outer_flat, z0 - t_radial], [x_outer_flat, z0 + handle_void_h + t_radial]],
            [ for (a = [90 : -2 : -90]) [ xo_c + (handle_void_h/2 + t_radial) * cos(a), zo_c + (handle_void_h/2 + t_radial) * sin(a) ] ]
        ));

        // Inner D void, extruded slightly larger in Y to ensure clean subtraction
        translate([0, -(t_depth/2 + 0.1), 0])
        rotate([-90, 0, 0])
        linear_extrude(height = t_depth + 0.2)
        polygon(points = concat(
            [[x_inner_flat, z0], [x_inner_flat, z0 + handle_void_h]],
            [ for (a = [90 : -2 : -90]) [ xi_c + (handle_void_h/2) * cos(a), zi_c + (handle_void_h/2) * sin(a) ] ]
        ));
    }
}