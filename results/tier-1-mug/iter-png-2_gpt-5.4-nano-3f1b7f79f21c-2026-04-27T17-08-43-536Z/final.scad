// Mug with hollow interior and radial ring handle
$fn = 128;

// Given dimensions
outer_d  = 80;      // outside diameter
body_h   = 100;     // height
wall_t   = 4;       // side wall thickness
bottom_t = 6;       // bottom thickness

outer_r = outer_d/2;
inner_r = outer_r - wall_t;

// Handle requirements (ring protruding outward in radial direction)
handle_rad_out = 12; // "半径 12mm の外径方向に飛び出す" => protruding major radius
handle_th = 10;      // handle thickness (height in Z)
handle_z  = body_h/2; // center height of handle

// Ensure ring thickness doesn't invert
hole_d = 6; // finger hole diameter
minor_outer = max(0.1, handle_th/2);
minor_inner = max(0.1, minor_outer - hole_d/2);

// -------------------- Geometry --------------------
module mug() {
    difference() {
        cylinder(h=body_h, r=outer_r);

        // Hollow interior (keep bottom thickness)
        translate([0,0,bottom_t])
            cylinder(h=body_h - bottom_t, r=inner_r);
    }
}

// Radial ring handle (torus) oriented so it protrudes in +X direction.
// The torus major radius is 'handle_rad_out', and its center is placed
// at the cup outer surface plane (x=outer_r), so it protrudes outward.
module ring_handle(rad=12, zc=50, ring_th=10, hole=6) {
    minor_outer_local = max(0.1, ring_th/2);
    minor_inner_local = max(0.1, minor_outer_local - hole/2);

    rotate([0,90,0]) {
        translate([outer_r, 0, zc])
            difference() {
                // Outer torus
                rotate_extrude(angle=360)
                    translate([rad, 0, 0])
                        circle(r=minor_outer_local);

                // Inner cutout to form a ring (finger hole)
                rotate_extrude(angle=360)
                    translate([rad, 0, 0])
                        circle(r=minor_inner_local);
            }
    }
}

union() {
    mug();
    // Place handle at cup center height
    // (protrudes outward from outer wall; ring is centered radially at x=outer_r)
    ring_handle(rad=handle_rad_out, zc=handle_z, ring_th=handle_th, hole=hole_d);
}