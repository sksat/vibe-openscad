// Mug with handle on +X side
// Body: outer_r=40, inner_r=35, height=90, bottom=6mm
// Handle: inner space 30mm(H) x 25mm(W), on +X side, centered at mug mid-height

$fn = 128;

outer_r = 40;
inner_r = 35;
mug_h   = 90;
bot_t   = 6;

// Handle design
// Cross-section radius of handle tube
tube_r = 6;

// Inner clear space of handle: 30mm tall, 25mm wide
h_space_h = 30;
h_space_w  = 25;

// Handle center Z
handle_z = mug_h / 2;  // = 45

// The handle path (centerline) lies in the Y=0 plane.
// The straight (mug-side) portions run vertically at X = outer_r + tube_r,
// from Z = handle_z - h_space_h/2  to  Z = handle_z + h_space_h/2
// (embedded into the mug wall for solid union)
//
// The outer arc is a circular arc connecting the two vertical ends,
// bulging in the +X direction.
//
// Arc geometry:
//   Endpoints in XZ plane:
//     P_bot = (outer_r + tube_r,  handle_z - h_space_h/2)
//     P_top = (outer_r + tube_r,  handle_z + h_space_h/2)
//   The arc must extend to X = outer_r + tube_r + h_space_w at Z = handle_z.
//
//   Let arc center = (cx, handle_z).
//   R = cx - (outer_r + tube_r)   [rightmost reach]   → cx = outer_r + tube_r + R - h_space_w ... wait
//   R = (outer_r + tube_r + h_space_w) - cx
//   Also passes through P_bot:
//     R^2 = (outer_r + tube_r - cx)^2 + (h_space_h/2)^2
//   Let A = outer_r + tube_r, B = h_space_h/2 = 15, W = h_space_w = 25
//   R = (A + W) - cx  →  cx = A + W - R
//   R^2 = (A - cx)^2 + B^2
//       = (A - (A + W - R))^2 + B^2
//       = (R - W)^2 + B^2
//   R^2 = R^2 - 2RW + W^2 + B^2
//   0 = -2RW + W^2 + B^2
//   R = (W^2 + B^2) / (2W)
//     = (625 + 225) / 50 = 850/50 = 17

arc_R  = (h_space_w*h_space_w + (h_space_h/2)*(h_space_h/2)) / (2*h_space_w);
// arc_R = 17

// Arc center X:
arc_cx = outer_r + tube_r + h_space_w - arc_R;
// = 40 + 6 + 25 - 17 = 54

// Angles of endpoints from arc center (in XZ plane, measured from +X axis):
// P_bot relative to arc center: (outer_r+tube_r - arc_cx,  -(h_space_h/2))
//   dx = 46 - 54 = -8,  dz = -15
// P_top: dx=-8, dz=+15
a_bot = atan2(-(h_space_h/2), (outer_r + tube_r) - arc_cx);  // atan2(-15,-8) ≈ -118.07°
a_top = atan2( (h_space_h/2), (outer_r + tube_r) - arc_cx);  // atan2(+15,-8) ≈ +118.07°
// Arc sweeps from a_bot to a_top through 0° (+X direction)

N_arc = 48;  // number of segments for arc

module handle() {
    union() {
        // --- Outer arc (tube swept along arc path) ---
        for (i = [0 : N_arc-1]) {
            a1 = a_bot + (a_top - a_bot) * i       / N_arc;
            a2 = a_bot + (a_top - a_bot) * (i+1)   / N_arc;
            x1 = arc_cx + arc_R * cos(a1);
            z1 = handle_z + arc_R * sin(a1);
            x2 = arc_cx + arc_R * cos(a2);
            z2 = handle_z + arc_R * sin(a2);
            hull() {
                translate([x1, 0, z1]) sphere(r = tube_r, $fn = 24);
                translate([x2, 0, z2]) sphere(r = tube_r, $fn = 24);
            }
        }

        // --- Top connection bar ---
        // From arc top endpoint back to mug body (X = 0 plane intersect, embed deep)
        x_top = arc_cx + arc_R * cos(a_top);
        z_top = handle_z + arc_R * sin(a_top);
        hull() {
            translate([x_top,       0, z_top]) sphere(r = tube_r, $fn = 24);
            translate([outer_r - 2, 0, z_top]) sphere(r = tube_r, $fn = 24);
        }

        // --- Bottom connection bar ---
        x_bot = arc_cx + arc_R * cos(a_bot);
        z_bot = handle_z + arc_R * sin(a_bot);
        hull() {
            translate([x_bot,       0, z_bot]) sphere(r = tube_r, $fn = 24);
            translate([outer_r - 2, 0, z_bot]) sphere(r = tube_r, $fn = 24);
        }
    }
}

module mug_body() {
    difference() {
        cylinder(r = outer_r, h = mug_h);
        translate([0, 0, bot_t])
            cylinder(r = inner_r, h = mug_h - bot_t + 0.1);
    }
}

// Final model
union() {
    mug_body();
    handle();
}