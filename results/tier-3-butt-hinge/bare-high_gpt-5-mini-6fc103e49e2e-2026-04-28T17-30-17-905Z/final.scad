// Butt hinge (butt hinge) OpenSCAD model
// 3 parts (left leaf, right leaf, pin) assembled in 180° open position
// Units: mm

$fn = 64; // global resolution for round parts

// --- Parameters ---
board_length      = 30;      // Y direction (hinge axis)
board_width       = 25;      // X direction (opening direction)
board_thickness   = 2;       // Z direction (plate thickness)

knuckle_segments  = 5;
knuckle_length    = board_length / knuckle_segments; // 6 mm each
knuckle_od        = 8;       // outer diameter
knuckle_id        = 4.6;     // inner diameter (pin + 0.3 mm clearance)

pin_diameter      = 4;
pin_length        = 32;      // 1 mm protruding both ends beyond knuckles

// Knuckle centers along Y (centered at Y=0)
knuckle_positions = [ -12, -6, 0, 6, 12 ];
left_knuckles     = [ -12, 0, 12 ];
right_knuckles    = [ -6, 6 ];

// Screw (M3) countersunk holes
hole_pitch        = 8;
hole_y            = [-8, 0, 8]; // three holes (8 mm pitch)
hole_margin       = 5;          // from outer edge of plate
hole_x_left       = -board_width + hole_margin; // -20
hole_x_right      =  board_width - hole_margin; // +20
countersink_diam  = 6;
countersink_depth = 1;
through_diam      = 3.2;

// --- Helper modules ---

module countersunk_hole_at(x, y) {
    // Countersink from top surface (z = board_thickness) downward by countersink_depth,
    // then a through hole of diameter through_diam for the remaining thickness.
    union() {
        // through hole (bottom part): from z=0 to z=(board_thickness - countersink_depth)
        translate([x, y, 0])
            cylinder(h = board_thickness - countersink_depth, r = through_diam/2, center = false, $fn=32);

        // countersink frustum: from z=(board_thickness - countersink_depth) to z=board_thickness
        translate([x, y, board_thickness - countersink_depth])
            cylinder(h = countersink_depth, r1 = through_diam/2, r2 = countersink_diam/2, center = false, $fn=32);
    }
}

// --- Part modules ---

module left_leaf() {
    difference() {
        union() {
            // left plate: occupies x in [-board_width .. 0], y in [-board_length/2 .. +board_length/2], z in [0 .. board_thickness]
            translate([-board_width, -board_length/2, 0])
                cube([board_width, board_length, board_thickness], center = false);

            // left knuckles (half-tubes for x <= 0)
            for (pos = left_knuckles) {
                intersection() {
                    // knuckle (outer tube minus inner bore), oriented along Y
                    translate([0, pos, 0]) rotate([-90,0,0])
                        difference() {
                            // outer cylinder
                            cylinder(h = knuckle_length, r = knuckle_od/2, center = true, $fn=64);
                            // inner bore (slightly longer to ensure clean subtraction)
                            cylinder(h = knuckle_length + 2, r = knuckle_id/2, center = true, $fn=64);
                        }
                    // clip to x <= 0 (keep negative X half)
                    translate([-200, pos - knuckle_length/2 - 1, -200])
                        cube([200, knuckle_length + 2, 400], center = false);
                }
            }
        }

        // subtract countersunk screw holes (on side away from knuckle)
        for (ypos = hole_y) {
            countersunk_hole_at(hole_x_left, ypos);
        }
    }
}

module right_leaf() {
    difference() {
        union() {
            // right plate: occupies x in [0 .. board_width]
            translate([0, -board_length/2, 0])
                cube([board_width, board_length, board_thickness], center = false);

            // right knuckles (half-tubes for x >= 0)
            for (pos = right_knuckles) {
                intersection() {
                    // knuckle (outer tube minus inner bore), oriented along Y
                    translate([0, pos, 0]) rotate([-90,0,0])
                        difference() {
                            cylinder(h = knuckle_length, r = knuckle_od/2, center = true, $fn=64);
                            cylinder(h = knuckle_length + 2, r = knuckle_id/2, center = true, $fn=64);
                        }
                    // clip to x >= 0 (keep positive X half)
                    translate([0, pos - knuckle_length/2 - 1, -200])
                        cube([200, knuckle_length + 2, 400], center = false);
                }
            }
        }

        // subtract countersunk screw holes (on side away from knuckle)
        for (ypos = hole_y) {
            countersunk_hole_at(hole_x_right, ypos);
        }
    }
}

module hinge_pin() {
    // Pin axis must be along +Y direction with centerline at Y=0.
    // Create cylinder centered at origin and rotate its axis to +Y.
    rotate([-90, 0, 0])
        cylinder(h = pin_length, r = pin_diameter/2, center = true, $fn = 64);
}

// --- Assembly (180° open: both leaves coplanar in XY plane, pin along Y) ---

// Optionally color parts for visual distinction:
color([0.8,0.8,0.8]) left_leaf();    // light gray left leaf
color([0.6,0.6,0.6]) right_leaf();   // darker gray right leaf
color([0.2,0.2,0.8]) hinge_pin();    // blue pin