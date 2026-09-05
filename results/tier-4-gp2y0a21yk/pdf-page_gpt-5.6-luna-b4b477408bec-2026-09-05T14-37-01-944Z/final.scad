/*
  Sharp GP2Y0A21YK0F
  Unit: mm

  Coordinate system:
    X : left / right
    Y : bottom / top
    Z : optical direction
        front / lens side = +Z
        PWB / connector side = -Z

  The origin is at the center of the main sensor body.
*/

$fn = 96;

// -----------------------------------------------------------------------------
// Parameters from the outline drawing
// -----------------------------------------------------------------------------

body_w       = 29.5;
body_h       = 13.5;
body_d       = 13.5;

lens_pitch   = 20.0;
lens_x       = lens_pitch / 2;

lens_case_r  = 3.75;
lens_r       = 2.75;
lens_depth   = 2.0;

mount_pitch  = 31.0;
mount_x      = mount_pitch / 2;
mount_r      = 3.10;
mount_hole_r = 1.60;

front_frame_h = 8.4;
front_frame_t = 1.0;

pwb_w        = 10.1;
pwb_h        = 4.15;
pwb_t        = 1.2;

connector_w  = 10.1;
connector_h  = 3.3;
connector_d  = 2.2;

pin_pitch    = 2.54;
pin_d        = 0.65;
pin_len      = 2.4;


// -----------------------------------------------------------------------------
// Utility modules
// -----------------------------------------------------------------------------

module box_centered(size = [10,10,10], pos = [0,0,0]) {
    translate(pos)
        cube(size, center = true);
}

module cylinder_z(r, h, z0 = 0, x = 0, y = 0) {
    translate([x, y, z0])
        cylinder(r = r, h = h, center = false);
}

module annular_ring_z(ro, ri, h, z0, x, y) {
    difference() {
        cylinder_z(ro, h, z0, x, y);
        cylinder_z(ri, h + 0.02, z0 - 0.01, x, y);
    }
}


// -----------------------------------------------------------------------------
// Main case
// -----------------------------------------------------------------------------

module main_case() {
    color([0.08, 0.08, 0.075]) {
        // Main carbonic ABS case
        box_centered(
            [body_w, body_h, body_d],
            [0, 0, 0]
        );

        // Slightly raised front bezel
        box_centered(
            [body_w, front_frame_h, front_frame_t],
            [0, 0, body_d/2 + front_frame_t/2]
        );

        // Rear lower shoulder around the PWB area
        box_centered(
            [body_w - 1.0, 4.2, 1.2],
            [0, -4.1, -body_d/2 - 0.6]
        );
    }
}


// -----------------------------------------------------------------------------
// Front optical section
// -----------------------------------------------------------------------------

module optical_lenses() {
    for (x = [-lens_x, lens_x]) {
        // Outer lens case / retaining ring
        color([0.12, 0.12, 0.11])
            annular_ring_z(
                lens_case_r,
                lens_r + 0.22,
                lens_depth,
                body_d/2 + front_frame_t - 0.15,
                x,
                0
            );

        // Lens glass
        color([0.18, 0.28, 0.30, 0.72])
            cylinder_z(
                lens_r,
                lens_depth + 0.18,
                body_d/2 + front_frame_t - 0.05,
                x,
                0
            );

        // Inner dark optical surface
        color([0.025, 0.035, 0.035])
            cylinder_z(
                lens_r - 0.35,
                0.18,
                body_d/2 + front_frame_t + lens_depth - 0.02,
                x,
                0
            );

        // Thin highlight ring
        color([0.28, 0.28, 0.25])
            annular_ring_z(
                lens_r + 0.10,
                lens_r - 0.12,
                0.10,
                body_d/2 + front_frame_t + lens_depth + 0.02,
                x,
                0
            );
    }
}


// -----------------------------------------------------------------------------
// Mounting ears with Ø3.2 mm holes
// -----------------------------------------------------------------------------

module mounting_ears() {
    color([0.08, 0.08, 0.075]) {
        for (x = [-mount_x, mount_x]) {
            difference() {
                union() {
                    // Circular mounting lug
                    cylinder_z(
                        mount_r,
                        1.8,
                        -0.9,
                        x,
                        0
                    );

                    // Short connection from lug to main case
                    box_centered(
                        [4.0, 5.8, 1.8],
                        [x > 0 ? -1.6 : 1.6, 0, 0]
                    );
                }

                // Through mounting hole
                cylinder_z(
                    mount_hole_r,
                    2.2,
                    -1.1,
                    x,
                    0
                );
            }
        }
    }
}


// -----------------------------------------------------------------------------
// PWB and connector on the -Z side
// -----------------------------------------------------------------------------

module rear_pwb() {
    // Paper PWB
    color([0.10, 0.38, 0.13])
        box_centered(
            [pwb_w, pwb_h, pwb_t],
            [0, -1.5, -body_d/2 - pwb_t/2]
        );

    // Connector housing, extending toward -Z
    color([0.12, 0.12, 0.11])
        box_centered(
            [connector_w, connector_h, connector_d],
            [0, -1.5, -body_d/2 - pwb_t - connector_d/2 + 0.05]
        );

    // Connector front lip
    color([0.18, 0.18, 0.17])
        box_centered(
            [connector_w + 0.25, connector_h + 0.25, 0.45],
            [0, -1.5,
             -body_d/2 - pwb_t - connector_d - 0.18]
        );

    // Three connector contacts, numbered 1, 2, 3 in the datasheet
    for (i = [-1, 0, 1]) {
        color([0.72, 0.72, 0.66])
            box_centered(
                [pin_d, 0.75, pin_len],
                [i * pin_pitch,
                 -1.5,
                 -body_d/2 - pwb_t - connector_d - pin_len/2 + 0.05]
            );
    }
}


// -----------------------------------------------------------------------------
// Small rear housing steps, based on the side outline
// -----------------------------------------------------------------------------

module rear_steps() {
    color([0.08, 0.08, 0.075]) {
        // Upper and lower rear shoulders
        box_centered(
            [16.3, 2.1, 2.0],
            [0, 5.7, -body_d/2 - 0.7]
        );

        box_centered(
            [7.5, 2.1, 2.0],
            [-10.9, 5.7, -body_d/2 - 0.7]
        );

        // Narrow central rear support
        box_centered(
            [6.3, 3.0, 1.8],
            [0, 2.9, -body_d/2 - 0.7]
        );
    }
}


// -----------------------------------------------------------------------------
// Complete sensor
// -----------------------------------------------------------------------------

module GP2Y0A21YK0F() {
    main_case();
    mounting_ears();
    optical_lenses();
    rear_pwb();
    rear_steps();
}

GP2Y0A21YK0F();