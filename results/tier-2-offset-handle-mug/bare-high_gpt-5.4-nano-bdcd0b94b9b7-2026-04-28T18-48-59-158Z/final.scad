$fn = 96;

// ---------------- Mug parameters ----------------
mug_outer_d = 80;
mug_inner_d = 70;      // inner diameter
mug_h       = 90;
mug_bottom  = 6;      // bottom thickness

// ---------------- Handle parameters ----------------
handle_opening_h = 30; // inner space height
handle_opening_w = 25; // inner space width (Y direction)

handle_wall   = 6;     // used to size outer D and side walls
attach_overlap = 0.5;  // ensure overlap with mug for robust union
eps = 0.2;

// Handle will be centered around the mug's height center
z_center = mug_h / 2;

// ---------------- Geometry helpers ----------------
module half_cyl_y(r, ylen, x_center, z_center) {
    // Cylinder axis is along Y; D shape is created by keeping only x >= x_center.
    intersection() {
        translate([x_center, 0, z_center])
            rotate([90, 0, 0])
                cylinder(r = r, h = ylen, center = true);

        translate([x_center, -ylen/2, z_center - r])
            cube([r, ylen, 2*r], center = false);
    }
}

module d_handle() {
    outer_r = handle_opening_h/2 + handle_wall; // outer semicircle radius
    inner_r = handle_opening_h/2;               // target semicircle radius for inner opening

    outer_ylen = handle_opening_w + 2*handle_wall;
    inner_ylen = handle_opening_w;

    mug_outer_r = mug_outer_d/2;
    x_flat_out  = mug_outer_r - attach_overlap; // outer D flat face plane
    x_flat_in   = x_flat_out + handle_wall;    // inner cavity flat face plane

    outer = half_cyl_y(outer_r, outer_ylen, x_flat_out, z_center);
    inner = half_cyl_y(inner_r - eps, inner_ylen - eps, x_flat_in, z_center);

    difference() { outer; inner; }
}

module mug_body() {
    difference() {
        cylinder(d = mug_outer_d, h = mug_h);

        // hollow interior
        translate([0, 0, mug_bottom])
            cylinder(d = mug_inner_d, h = mug_h - mug_bottom + 0.1);
    }
}

// ---------------- Assembly ----------------
union() {
    mug_body();
    // attach only on +X side by construction of the handle (x >= flat face plane)
    d_handle();
}