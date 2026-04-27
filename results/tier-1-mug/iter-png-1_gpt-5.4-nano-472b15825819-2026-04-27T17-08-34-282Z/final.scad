// Mug with hollow interior and radial ring handle
$fn = 128;

// Given dimensions
outer_d  = 80;      // outside diameter
body_h   = 100;     // height
wall_t   = 4;       // side wall thickness
bottom_t = 6;       // bottom thickness

outer_r = outer_d/2;
inner_r = outer_r - wall_t;

// Handle requirements
handle_radius_extrude = 12; // ring's radius that protrudes outward (radially)
handle_th = 10;              // ring thickness (height in Z)
handle_z  = body_h/2;       // center height of handle

// -------------------- Geometry --------------------
module mug() {
    // Outer shell
    difference() {
        cylinder(h=body_h, r=outer_r);

        // Hollow interior (keep bottom thickness)
        translate([0,0,bottom_t])
            cylinder(h=body_h - bottom_t, r=inner_r);
    }
}

module ring_handle(rad=12, zc=50, ring_th=10, hole=6) {
    /*
      Radial ring oriented so it protrudes in +X direction from the cup wall.
      Implemented as a torus whose major radius is 'rad' and whose minor
      radius is ring_th/2, then cut out an inner hole to make it a ring
      (so a finger can pass).
      
      Position: center of ring cross-section is located at the cup's outer
      surface plane (x=outer_r), and the ring extends further outward
      to x=outer_r + rad*2 (i.e., "外径方向に飛び出す").
    */
    minor_outer = ring_th/2;

    // Safety for subtraction
    minor_inner = max(0.1, minor_outer - hole);

    // Torus constructed from rotate_extrude of an annulus cross-section.
    // Major radius uses translate([rad,0,z]) before rotate_extrude.
    rotate([0,90,0])  // make torus axis align such that it protrudes radially in +X
    translate([outer_r, 0, zc])
    difference() {
        // Outer torus
        rotate_extrude(angle=360)
            translate([rad, 0, 0])
                circle(r=minor_outer);

        // Inner cutout (hole)
        rotate_extrude(angle=360)
            translate([rad, 0, 0])
                circle(r=minor_inner);
    }
}

union() {
    mug();
    // Place handle at cup center height, centered on the outer wall plane,
    // protruding outward with major radius=12.
    ring_handle(rad=handle_radius_extrude, zc=handle_z, ring_th=handle_th, hole=6);
}