// Mug with hollow interior and outward ring handle (radial)

$fn = 128;

// Dimensions from prompt
outer_d  = 80;     // outer diameter
body_h   = 100;    // height
wall_t   = 4;      // side thickness
bottom_t = 6;     // bottom thickness

outer_r = outer_d/2;
inner_r = outer_r - wall_t;

// Handle (ring) parameters
handle_major_r = 12;   // "半径 12mm" => ring major radius
handle_zc = body_h/2;  // attach at cup center height
handle_th = 10;        // ring cross-section thickness along Z
finger_hole_d = 6;    // finger hole diameter

module mug() {
    difference() {
        // outer shell
        cylinder(h=body_h, r=outer_r);

        // hollow interior leaving bottom thickness
        translate([0,0,bottom_t])
            cylinder(h=body_h - bottom_t, r=inner_r);
    }
}

// Ring handle created as a torus, oriented to protrude radially outward (+X)
module ring_handle(major_r, zc, ring_th, hole_d) {
    // Torus minor radius is set by ring_th/2.
    // The finger hole is modeled by subtracting a smaller torus (same major radius).
    minor_outer = max(0.5, ring_th/2);
    minor_inner = max(0.5, minor_outer - hole_d/2);

    rotate([0,90,0]) {
        // Place torus so that its center lies at the cup outer surface (x = outer_r)
        // => it protrudes outward from the cup.
        translate([outer_r, 0, zc])
            difference() {
                // outer torus
                rotate_extrude(angle=360)
                    translate([major_r, 0, 0])
                        circle(r=minor_outer);

                // inner cutout torus to form finger hole
                rotate_extrude(angle=360)
                    translate([major_r, 0, 0])
                        circle(r=minor_inner);
            }
    }
}

union() {
    mug();
    ring_handle(handle_major_r, handle_zc, handle_th, finger_hole_d);
}