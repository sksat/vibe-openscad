$fn = 64;

// L-bracket parameters
plate_thickness = 3;   // both plates 3 mm thick
hor_width = 50;
hor_depth = 40;
vert_width = 50;
vert_height = 40;
hole_diameter = 4.5;
hole_radius = hole_diameter / 2; // 2.25
countersink_diameter = 8;
countersink_radius = countersink_diameter / 2; // 4
countersink_depth = 2;

// Hole centers (as described)
hor_hole_x = [10, 40];     // along X on horizontal plate
hor_hole_y = 20;            // centerline of horizontal plate (along Y)
vert_hole_x = [10, 40];     // along X on vertical plate
vert_hole_z = 20;            // centerline of vertical plate (along Z)
vert_hole_y_outer = 3;       // outer face at +Y side for vertical plate

module LBracket() {
    difference() {
        // Base L-bracket (two flanges)
        union() {
            // Horizontal flange: 50 (X) × 40 (Y) × 3 (Z)
            translate([0, 0, 0]) cube([hor_width, hor_depth, plate_thickness]);
            // Vertical flange: 50 (X) × 3 (Y) × 40 (Z)
            translate([0, 0, 0]) cube([vert_width, plate_thickness, vert_height]);
        }

        // Countersunk through-holes on horizontal flange (top, outer side)
        // 2 holes on centerline, 10 mm from each edge along X
        for (dx = hor_hole_x) {
            // Through hole
            translate([dx, hor_hole_y, 0]) cylinder(h = plate_thickness, r = hole_radius);
            // Countersink seat on outer (top) surface
            translate([dx, hor_hole_y, plate_thickness - countersink_depth + 0.0])
                cylinder(h = countersink_depth, r1 = hole_radius, r2 = countersink_radius);
        }

        // Holes on vertical flange (outer face at +Y)
        // 2 holes along X, centered Z = 20, through thickness Y (3 mm)
        for (dx = vert_hole_x) {
            // Through hole oriented along +Y (need to rotate from Z to Y)
            translate([dx, 0, vert_hole_z])
                rotate([90, 0, 0])
                    cylinder(h = plate_thickness, r = hole_radius);
        }

        // Countersink seats on vertical flange outer face (outer +Y side)
        // Each countersink sits on outer face at y = +3, depth 2 mm toward inner
        for (dx = vert_hole_x) {
            translate([dx, vert_hole_y_outer, vert_hole_z])
                rotate([-90, 0, 0])
                    cylinder(h = countersink_depth, r1 = hole_radius, r2 = countersink_radius);
        }

        // Note: The above vertical-hole operations use rotation to align holes with +Y axis.
        // The hole centers are set so their axes pass through the vertical flange thickness
        // (0 <= y <= 3) and through z ~ 20, keeping holes within the vertical flange.
    }
}

LBracket();