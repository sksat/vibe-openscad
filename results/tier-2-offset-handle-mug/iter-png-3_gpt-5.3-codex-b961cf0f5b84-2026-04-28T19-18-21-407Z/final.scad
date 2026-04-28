$fn = 128;

// ===== Mug dimensions =====
outer_d  = 80;   // mm
inner_d  = 70;   // mm
mug_h    = 90;   // mm
bottom_t = 6;    // mm

// ===== Handle inner opening requirement =====
// inner void: height 30mm (Z) x width 25mm (radial X)
void_h = 30;
void_w = 25;

// ===== Handle thickness =====
t_radial = 5;    // wall thickness in XZ profile
t_depth  = 12;   // thickness along Y (grip depth)

// Vertical center of handle
zc = mug_h / 2;

// Mug outer radius
r_outer = outer_d / 2;

// ----- D profile parameters (in XZ plane) -----
ri = void_h / 2;            // 15 (inner semicircle radius)
x_ci = r_outer + void_w;    // inner semicircle center X
zi0 = zc - void_h/2;
zi1 = zc + void_h/2;

// outer profile offset from inner profile
ro = ri + t_radial;         // 20
x_co = x_ci + t_radial;
zo0 = zi0 - t_radial;
zo1 = zi1 + t_radial;

// overlap into mug to guarantee manifold union
eps = 1.0;
x_flat_inner = r_outer - eps;          // inner flat of handle body enters mug
x_flat_outer = x_flat_inner + t_radial;

// D-shape polygon: flat side at x_flat, semicircle bulging to +X
module d_profile(x_flat, z0, z1, x_c, r) {
    polygon(points = concat(
        [[x_flat, z0], [x_flat, z1]],
        [for (a = [90:-2:-90]) [x_c + r*cos(a), zc + r*sin(a)]]
    ));
}

// Mug body with hollow interior and bottom thickness
module mug_body() {
    difference() {
        cylinder(h = mug_h, d = outer_d);
        translate([0, 0, bottom_t])
            cylinder(h = mug_h - bottom_t + 0.01, d = inner_d);
    }
}

// Handle solid (before carving its opening), centered on +X side
module handle_outer() {
    translate([0, -t_depth/2, 0])
        rotate([-90, 0, 0])
            linear_extrude(height = t_depth)
                d_profile(x_flat_outer, zo0, zo1, x_co, ro);
}

// Inner void of handle (kept tangent at mug outer surface)
module handle_inner_void() {
    translate([0, -(t_depth/2 + 0.1), 0])
        rotate([-90, 0, 0])
            linear_extrude(height = t_depth + 0.2)
                d_profile(r_outer, zi0, zi1, x_ci, ri);
}

// Final model
union() {
    mug_body();
    difference() {
        handle_outer();
        handle_inner_void();
    }
}