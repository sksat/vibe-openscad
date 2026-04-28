$fn = 128;

// Parameters
outer_d   = 80;
inner_d   = 70;
height    = 90;
base_th   = 6;

handle_gap_w = 25;   // inner width of handle opening
handle_gap_h = 30;   // inner height of handle opening
handle_th    = 8;    // radial thickness of handle
handle_outset = 10;   // outward extension beyond mug outer surface

module mug_body() {
    difference() {
        cylinder(h = height, d = outer_d);
        translate([0,0,base_th])
            cylinder(h = height - base_th + 0.02, d = inner_d);
    }
}

module handle_2d() {
    // D-shape profile: straight side on mug, semicircular outer side
    r = handle_gap_w / 2;
    polygon(points = [
        [0, -r],
        [0,  r],
        [handle_th,  r],
        [handle_th, -r]
    ]);
}

module handle() {
    // Place handle on +X side, centered vertically
    translate([outer_d/2 - 0.01, 0, height/2 - handle_gap_h/2])
        rotate([0,90,0])
            linear_extrude(height = handle_outset)
                offset(r = 0) // keeps 2D clean
                    difference() {
                        // Outer shape
                        offset(r = 0)
                            hull() {
                                translate([0,0]) circle(d = handle_gap_w);
                                translate([handle_th,0]) circle(d = handle_gap_w);
                            }
                        // Inner opening
                        translate([handle_th,0])
                            square([0.001,0.001], center=true);
                    }
}

module handle_clean() {
    // Build a robust D-shaped handle as a 3D solid using hull of two cylinders.
    // The opening dimensions are set by the cylinder diameter and spacing.
    r = handle_gap_w/2;

    translate([outer_d/2 - 0.01, 0, height/2 - handle_gap_h/2]) {
        rotate([0,90,0]) {
            hull() {
                translate([0, 0, 0])
                    cylinder(h = handle_outset, r = r, center = false);
                translate([0, 0, handle_th])
                    cylinder(h = handle_outset, r = r, center = false);
            }
        }
    }
}

union() {
    mug_body();
    // Handle placed only on +X side, centered vertically
    // The handle body intersects the mug wall for a manifold union.
    translate([0,0,0])
        handle_clean();
}