// openscad
// Small butt hinge for furniture (assembled, 180° open)
// - Two leaves (30x25x2 mm) with alternating knuckles (3 left, 2 right)
// - Pin: Ø4 mm, length 32 mm (1 mm protruding each end)
// - Knuckle outer Ø8 mm, inner bore Ø4.6 mm (Ø4 pin + 0.3 mm clearance)
// - Knuckle positions: Y = [-12, -6, 0, 6, 12] (segments of 6 mm)
// - Left knuckles: Y = [-12, 0, 12] ; Right knuckles: Y = [-6, 6]
// - Countersunk M3 holes (3 per leaf) at Y = [-8, 0, 8], X away from knuckles

$fn = 64;

// Parameters
plate_len = 30;       // Y direction
plate_w = 25;         // X direction (from hinge outward)
thickness = 2;        // Z thickness
half_th = thickness / 2;

knuckle_seg = 6;      // each knuckle segment length along Y
knuckle_positions = [-12, -6, 0, 6, 12];
left_knuckles = [-12, 0, 12];
right_knuckles = [-6, 6];

knuckle_r_out = 4;    // outer radius (Ø8)
knuckle_r_in = 2.3;   // inner bore radius (Ø4.6)

pin_dia = 4;
pin_r = pin_dia / 2;
pin_len = 32;         // along Y (extends 1 mm beyond knuckles each end)

screw_hole_positions = [-8, 0, 8];
screw_countersink_diam = 6;    // top diameter
screw_countersink_depth = 1;
screw_through_dia = 3.2;       // through hole
screw_offset_from_outer_edge = 5; // mm inward from outer edge along X

// Main assembly
union() {
    // Left leaf (x < 0)
    color("silver") left_leaf();

    // Right leaf (x > 0)
    color("silver") right_leaf();

    // Pin (separate part)
    color("gray") pin();
}


// Modules

module left_leaf() {
    // Base plate positioned from X = -25 .. 0, center at X = -12.5
    translate([-plate_w/2, 0, 0])
        difference() {
            // Plate body
            translate([0, 0, 0]) cube([plate_w, plate_len, thickness], center=true);

            // Add knuckles (full cylinders) for left leaf (unioned with plate)
            // We'll union knuckles after creating a union, so place here by union block
            // But since we are in difference(), we need to union the knuckles with the plate first.
            // To simplify, rebuild as union of plate+knuckles then subtract holes below.
        }

    // Build left leaf as union then subtract screw holes and knuckle bores
    translate([-plate_w/2, 0, 0])
        difference() {
            // Union of plate and knuckles
            union() {
                // Plate
                cube([plate_w, plate_len, thickness], center=true);

                // Knuckles (full cylinders along Y) at left_knuckles
                for (ypos = left_knuckles) {
                    translate([0, ypos, 0])
                        rotate([90, 0, 0])
                            cylinder(h=knuckle_seg, r=knuckle_r_out, center=true);
                }
            }

            // Subtract knuckle inner bores (for the left knuckles)
            for (ypos = left_knuckles) {
                translate([0, ypos, 0])
                    rotate([90, 0, 0])
                        cylinder(h= (plate_len + 20), r=knuckle_r_in, center=true);
            }

            // Subtract screw countersink + through holes (on side away from knuckles)
            // For left plate, outer edge at X = -plate_w. We placed plate with center at x=0 in this block,
            // so actual plate X range is [-plate_w/2 .. +plate_w/2] before earlier translate.
            // But we already translated leaf by -plate_w/2 above in outer placement,
            // so here in this block cube was centered and then the whole leaf was translated earlier.
            // To place holes relative to leaf local coordinates (centered), compute local X:
            // Local plate center is at X=0 here; outer edge (away from hinge) is at X = -plate_w/2.
            // Put holes at X = -plate_w/2 + screw_offset_from_outer_edge
            local_hole_x = -plate_w/2 + screw_offset_from_outer_edge;

            for (hy = screw_hole_positions) {
                // Through hole (cylinder along Z)
                translate([local_hole_x, hy, 0])
                    cylinder(h = thickness + 4, r = screw_through_dia/2, center=true);

                // Countersink frustum: place from z = 0 (midplane) up to z = +1 (top surface is +1)
                // Our plate center is z=0, thickness 2 -> top at +1, bottom at -1.
                translate([local_hole_x, hy, 0])
                    // frustum starting at z = 0 up to z = 1 (center=false means base at translate z)
                    // So we need to shift z=0 exactly at plate midplane; this frustum will go from 0..1
                    // which corresponds to center->top half of plate. That's desired: countersink depth=1.
                    cylinder(h = screw_countersink_depth, r1 = screw_countersink_diam/2, r2 = screw_through_dia/2, center=false);
            }
        }

    // Now translate the whole left leaf so its center is at X = -12.5 (i.e., spanning -25 .. 0)
    translate([-plate_w/2, 0, 0]) // this matches the earlier top-level placement pattern
        /* no-op to keep transform stack consistent */;
}

// Right leaf module
module right_leaf() {
    // Build right leaf as union then subtract holes and bores, similar to left but mirrored in X
    translate([plate_w/2, 0, 0])
        difference() {
            union() {
                cube([plate_w, plate_len, thickness], center=true);

                // Knuckles for right leaf
                for (ypos = right_knuckles) {
                    translate([0, ypos, 0])
                        rotate([90, 0, 0])
                            cylinder(h=knuckle_seg, r=knuckle_r_out, center=true);
                }
            }

            // Subtract knuckle inner bores (for the right knuckles)
            for (ypos = right_knuckles) {
                translate([0, ypos, 0])
                    rotate([90, 0, 0])
                        cylinder(h= (plate_len + 20), r=knuckle_r_in, center=true);
            }

            // Screw holes on outer side (away from hinge) for right leaf
            // Local plate center at X=0; outer edge at +plate_w/2
            local_hole_x = plate_w/2 - screw_offset_from_outer_edge;

            for (hy = screw_hole_positions) {
                translate([local_hole_x, hy, 0])
                    cylinder(h = thickness + 4, r = screw_through_dia/2, center=true);

                translate([local_hole_x, hy, 0])
                    cylinder(h = screw_countersink_depth, r1 = screw_countersink_diam/2, r2 = screw_through_dia/2, center=false);
            }
        }

    // Place it so it spans X = 0 .. +25
    translate([plate_w/2, 0, 0])
        /* no-op to keep transform stack consistent */;
}

// Pin module (separate part)
module pin() {
    // Pin is along Y, center at origin, length pin_len -> extends from Y = -pin_len/2 .. +pin_len/2
    // This will protrude 1 mm beyond knuckles which span Y = -15 .. +15 (pin length 32 => ±16)
    rotate([90, 0, 0]) // rotate cylinder (Z->Y)
        translate([0, 0, 0]) // center already at origin
            cylinder(h = pin_len, r = pin_r, center=true);
}