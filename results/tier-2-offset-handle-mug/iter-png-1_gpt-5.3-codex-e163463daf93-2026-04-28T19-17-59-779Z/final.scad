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
t_radial = 5;    // ring thickness in XZ profile
t_depth  = 10;   // thickness along Y

r_outer = outer_d / 2;

// Centers for vertical placement (middle of mug)
zc = mug_h / 2;
zi0 = zc - void_h/2;
zi1 = zc + void_h/2;

// D-profile radii (in XZ)
ri = void_h / 2;          // inner semicircle radius = 15
ro = ri + t_radial;       // outer semicircle radius = 20

// X positions so inner flat side touches mug at +X tangent plane
x_flat_inner = r_outer;               // contact plane with mug
x_flat_outer = x_flat_inner + t_radial;

x_ci = x_flat_inner + void_w;         // inner semicircle center x
x_co = x_flat_outer + void_w + t_radial; // outer semicircle center x

module d_profile(x_flat, z0, z1, x_c, r) {
    polygon(points = concat(
        [[x_flat, z0], [x_flat, z1]],
        [for (a = [90:-2:-90]) [x_c + r*cos(a), zc + r*sin(a)]]
    ));
}

module mug_body() {
    difference() {
        cylinder(h = mug_h, d = outer_d);
        translate([0,0,bottom_t])
            cylinder(h = mug_h - bottom_t + 0.01, d = inner_d);
    }
}

module handle() {
    // D-ring extruded along Y and centered at y=0
    difference() {
        translate([0, -t_depth/2, 0])
            rotate([-90,0,0])
                linear_extrude(height = t_depth)
                    d_profile(x_flat_outer, zi0 - t_radial, zi1 + t_radial, x_co, ro);

        translate([0, -(t_depth/2 + 0.1), 0])
            rotate([-90,0,0])
                linear_extrude(height = t_depth + 0.2)
                    d_profile(x_flat_inner, zi0, zi1, x_ci, ri);
    }
}

union() {
    mug_body();
    handle();   // attached on +X side only
}