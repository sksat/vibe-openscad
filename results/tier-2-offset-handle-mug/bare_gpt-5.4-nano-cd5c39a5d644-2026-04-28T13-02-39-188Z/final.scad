// Mug with D-handle, OpenSCAD

$fn = 128;

// ---------------- Parameters ----------------
outer_d = 80;
inner_d = 70;
wall = 5;

cup_h = 90;
bottom_th = 6;

handle_depth_x = 25;     // width in +X/-X direction for the inner cavity
handle_inner_h = 30;    // height of the inner cavity
handle_outer_r = 12.5;  // radius of the outer semicircle (gives ~25mm diameter in X)

handle_center_z = cup_h/2; // central height for handle

// ---------------- Helper Modules ----------------
module mug_body() {
    difference() {
        // Outer cylinder (cup)
        translate([0,0,bottom_th/2])
            cylinder(h = cup_h + bottom_th, d = outer_d);

        // Inner cavity (start at bottom thickness so bottom remains solid)
        translate([0,0,bottom_th])
            cylinder(h = cup_h, d = inner_d);
    }
}

module d_handle() {
    // Create a "D" shape by taking a half-cylinder (outer) and a rectangular cut (flat side)
    // The handle will be attached only on +X side of the mug.
    //
    // We'll create a 2D profile in the Y-Z plane at x=0, then linear_extrude along X.
    // The flat side of the D faces the mug center (toward -X), and the curved side is outward (+X).
    linear_extrude(height = handle_depth_x, center = true) {
        // D profile in Y-Z:
        // Outer semi-circle radius handle_outer_r
        // Flat side is the diameter chord.
        // Centered at Z = handle_center_z and Y = 0 (we'll rotate/position later).
        union() {
            // Semi-circle (curved outer part)
            translate([0, handle_center_z]) 
                intersection() {
                    circle(r = handle_outer_r);
                    // Keep only the outer half (y >= 0) to make semicircle
                    translate([0,0]) square([handle_outer_r*2, handle_outer_r*2], center=true);
                }

            // Flat continuation below/above to make the straight side clean:
            // (No extra needed; the intersection already limits to semicircle.)
        }
        // Cut away inside area to make the handle cavity D-shaped.
        // Keep roughly matching cavity height 30 and width 25.
        // We'll cut a smaller D shape from within.
        difference() {
            // Outer D (semi-circle) + flat chord
            translate([0, handle_center_z])
                difference() {
                    // Semi-circle shell boundary
                    intersection() {
                        circle(r = handle_outer_r);
                        square([handle_outer_r*2, handle_outer_r*2], center=true);
                    }
                }

            // Inner cavity D-shaped cut (smaller semi-circle)
            translate([0, handle_center_z])
                intersection() {
                    circle(r = (handle_outer_r - wall)); // cavity curvature
                    square([ (handle_outer_r)*2, (handle_outer_r)*2 ], center=true);
                }
        }
    }
}

// More precise handle: build in 3D as a union of outer D-volume minus inner D-volume,
// and position/attach to +X side of the mug.
module handle_3d() {
    // Outer D volume (half-cylinder + flat) extruded along X for depth handle_depth_x
    // We'll construct the handle in its own local coords:
    // - Curved part centered on Y=0, Z=handle_center_z
    // - Handle extends along +X from mug surface (we will position by translating to +X side)
    //
    // Approach:
    // Build outer shell as half-cylinder extruded along X with a flat side created by masking,
    // then subtract inner half-cylinder and rectangular block to create the D cavity.

    // Outer shape
    outer = union() {
        // Outer half-cylinder (in Y direction cross-section) extruded along X
        translate([0,0,0])
            intersection() {
                // Half-cylinder centered at Y=0, Z=handle_center_z
                // Cylinder axis along X -> we use rotate to align cylinder with X
                // Then diameter is 2*handle_outer_r in Y-Z plane.
                rotate([0,90,0])
                    cylinder(h = handle_depth_x, r = handle_outer_r);

                // Keep only the "outer half" (curved side away from mug), i.e., Y >= 0 in local cross-section
                translate([0,0,0])
                    cube([handle_depth_x + 1, handle_outer_r*2 + 2, handle_outer_r*2 + 2], center=false);
            }
        // Add a rectangular prism to ensure flat side reaches the chord plane cleanly
        translate([ -handle_depth_x/2, 0, handle_center_z - handle_outer_r ])
            cube([handle_depth_x, handle_outer_r, handle_outer_r*2], center=false);
    };

    // Inner cavity shape (D cavity)
    inner = union() {
        // Inner half-cylinder for cavity (smaller radius)
        rotate([0,90,0])
            cylinder(h = handle_depth_x + 2, r = (handle_outer_r - wall - 0.5));

        // Flatten the inner cavity (straight side)
        translate([ -handle_depth_x/2 - 1, 0, handle_center_z - (handle_outer_r - wall - 0.5) ])
            cube([handle_depth_x + 2, (handle_outer_r - wall - 0.5), (handle_outer_r - wall - 0.5)*2], center=false);
    };

    // Final handle: outer minus inner cavity, then reposition to attach to +X side
    difference() {
        outer;
        // Align inner with outer in local coords
        translate([0,0,0]) inner;
    }
}

// ---------------- Assemble ----------------
difference() {
    union() {
        mug_body();

        // Attach handle only to +X side at the cup's outer surface.
        //
        // The mug's center is at (0,0,0) horizontally, with base starting at z=0.
        // Mug outer radius:
        mug_r = outer_d/2;

        // Place handle such that its curved part sits on the +X side of the mug.
        // handle outer flat side should face the mug (+X attachment region);
        // We'll position the handle so that local Y axis corresponds to tangential direction (around mug),
        // but because mug is axisymmetric, we can align handle profile in Y-Z and extrude in X.
        //
        // We construct the handle centered at Y=0 (so it's centered around the X-axis plane)
        // and at Z=handle_center_z.
        //
        // The handle depth in X is handle_depth_x; place it so its inner flat side mates to the mug outer surface.
        // Since our handle is built around X in local coords, center at x=0; move to start at mug_r.
        translate([mug_r + (handle_depth_x/2) - 0.01, 0, 0])
            translate([0,0,0])
                // Position in Z by shifting profile center
                // Our handle_3d uses handle_center_z already; so just call it with no extra Z.
                handle_3d();
    }
    // No cuts needed; ensure no self-intersections create visible seams.
}

// Optional: slight smoothing union artifacts by enabling higher resolution ($fn above).