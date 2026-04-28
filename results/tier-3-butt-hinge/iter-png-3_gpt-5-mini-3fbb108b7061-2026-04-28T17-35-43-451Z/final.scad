// openscad
// Fixed small butt hinge (assembled, 180° open)
// Two leaves (30 x 25 x 2 mm), pin along Y, leaves lie flat in same plane (Z)
// Knuckles: 5 segments (each 6 mm long along Y) at Y = [-12, -6, 0, 6, 12]
// Left knuckles at [-12, 0, 12], right knuckles at [-6, 6]
// Knuckle outer Ø8 mm, inner bore Ø4.6 mm
// Pin Ø4 mm, length 32 mm (1 mm protruding each end)
// Countersunk M3 holes (3 per leaf) at Y = [-8, 0, 8], 5 mm from outer edge
// Countersink Ø6 mm x depth 1 mm + through Ø3.2 mm
// Coordinate system: pin centerline on Y axis, leaves extend in X (left x<0, right x>0)

$fn = 64;

// Dimensions
plate_len = 30;       // along Y
plate_w = 25;         // along X (from hinge outward)
thickness = 2;        // along Z
half_th = thickness / 2;

knuckle_seg = 6;      // each segment length along Y
knuckle_positions = [-12, -6, 0, 6, 12];
left_knuckles = [-12, 0, 12];
right_knuckles = [-6, 6];

knuckle_r_out = 4;    // outer radius (Ø8)
knuckle_r_in = 2.3;   // inner bore radius (Ø4.6)

pin_dia = 4;
pin_r = pin_dia / 2;
pin_len = 32;         // along Y

screw_hole_positions = [-8, 0, 8];
screw_countersink_diam = 6;    // top diameter
screw_countersink_depth = 1;
screw_through_dia = 3.2;       // through hole
screw_offset_from_outer_edge = 5; // mm inward from outer edge along X

// Parts (placed assembled, 180° open)
color("silver") left_leaf();
color("silver") right_leaf();
color("gray") pin();

module left_leaf() {
    difference() {
        // Plate body + left knuckles (half of knuckle cylinders)
        union() {
            // plate (X from -plate_w .. 0)
            translate([-plate_w, -plate_len/2, -half_th])
                cube([plate_w, plate_len, thickness]);

            // knuckles intersected with left plate half-space
            for (ypos = left_knuckles) {
                intersection() {
                    // full knuckle cylinder (axis along Y)
                    translate([0, ypos, 0])
                        rotate([90, 0, 0])
                            cylinder(h = knuckle_seg, r = knuckle_r_out, center = true);
                    // left plate half-space box to cut the half knuckle
                    translate([-plate_w, -plate_len/2, -100])
                        cube([plate_w, plate_len, 200]);
                }
            }
        }

        // subtract knuckle bores (through the knuckles)
        for (ypos = left_knuckles) {
            translate([0, ypos, 0])
                rotate([90, 0, 0])
                    cylinder(h = 100, r = knuckle_r_in, center = true);
        }

        // subtract screw holes + countersinks (from top surface Z = +half_th)
        for (hy = screw_hole_positions) {
            hole_x = -plate_w + screw_offset_from_outer_edge;
            // through hole
            translate([hole_x, hy, -half_th - 1])
                cylinder(h = thickness + 2, r = screw_through_dia / 2, center = false);
            // countersink (frustum) from top
            translate([hole_x, hy, half_th - screw_countersink_depth])
                cylinder(h = screw_countersink_depth, r1 = screw_through_dia / 2, r2 = screw_countersink_diam / 2, center = false);
        }
    }
}

module right_leaf() {
    difference() {
        // Plate body + right knuckles (half of knuckle cylinders)
        union() {
            // plate (X from 0 .. plate_w)
            translate([0, -plate_len/2, -half_th])
                cube([plate_w, plate_len, thickness]);

            // knuckles intersected with right plate half-space
            for (ypos = right_knuckles) {
                intersection() {
                    // full knuckle cylinder (axis along Y)
                    translate([0, ypos, 0])
                        rotate([90, 0, 0])
                            cylinder(h = knuckle_seg, r = knuckle_r_out, center = true);
                    // right plate half-space box to cut the half knuckle
                    translate([0, -plate_len/2, -100])
                        cube([plate_w, plate_len, 200]);
                }
            }
        }

        // subtract knuckle bores (through the knuckles)
        for (ypos = right_knuckles) {
            translate([0, ypos, 0])
                rotate([90, 0, 0])
                    cylinder(h = 100, r = knuckle_r_in, center = true);
        }

        // subtract screw holes + countersinks (from top surface Z = +half_th)
        for (hy = screw_hole_positions) {
            hole_x = plate_w - screw_offset_from_outer_edge;
            // through hole
            translate([hole_x, hy, -half_th - 1])
                cylinder(h = thickness + 2, r = screw_through_dia / 2, center = false);
            // countersink (frustum) from top
            translate([hole_x, hy, half_th - screw_countersink_depth])
                cylinder(h = screw_countersink_depth, r1 = screw_through_dia / 2, r2 = screw_countersink_diam / 2, center = false);
        }
    }
}

module pin() {
    // Pin axis along Y, centered at origin. Pin length extends 1 mm beyond knuckle ends.
    translate([0, 0, 0])
        rotate([90, 0, 0])
            cylinder(h = pin_len, r = pin_r, center = true);
}