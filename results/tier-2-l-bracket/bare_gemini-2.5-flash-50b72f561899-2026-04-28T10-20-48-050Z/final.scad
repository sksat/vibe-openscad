// L-bracket parameters
flange_width = 50;
flange_depth_horiz = 40;
flange_height_vert = 40;
plate_thickness = 3;

// Countersunk hole parameters (M4 screw)
// M4 specifies a major diameter of 4mm.
// A common clearance hole diameter is 4.5mm.
// A common countersunk head diameter is 8mm, with a depth of 2mm.
cs_hole_depth_cs = 2; // Depth of the conical countersunk part
cs_hole_radius_top = 8 / 2; // Radius at the top of the countersunk part
cs_hole_radius_bottom = 4.5 / 2; // Radius at the bottom of the countersunk part (same as through hole)
thru_hole_radius = 4.5 / 2; // Radius of the straight through hole

// Overall depth for the hole operation to ensure complete cut through the plate
hole_overall_depth = plate_thickness + 2; // plate_thickness (3mm) + extra (2mm) = 5mm

// Hole placement parameters
hole_margin = 10; // Distance from the edge to the center of the hole

// Module for a countersunk hole, defined to originate at [0,0,0] and extend along the +Z axis.
// This allows easy rotation and translation to position the holes.
module countersunk_hole_m4() {
    union() {
        // Conical countersunk part
        cylinder(h = cs_hole_depth_cs, r1 = cs_hole_radius_top, r2 = cs_hole_radius_bottom, $fn = 64);
        // Straight through hole part, starting from where the countersunk part ends
        translate([0, 0, cs_hole_depth_cs])
        cylinder(h = hole_overall_depth - cs_hole_depth_cs, r = thru_hole_radius, $fn = 64);
    }
}

difference() {
    // 1. Main L-bracket shape
    union() {
        // Horizontal flange:
        // Dimensions: [width, depth, thickness] = [50mm, 40mm, 3mm]
        // Placed with inner corner at [0,0,0].
        // Extends from X=0 to 50, Y=0 to 40, Z=0 to 3.
        // +Y direction is depth, +Z direction is upwards (thickness).
        cube([flange_width, flange_depth_horiz, plate_thickness]);

        // Vertical flange:
        // Dimensions: [width, thickness, height] = [50mm, 3mm, 40mm]
        // Placed with inner corner at [0,0,0].
        // Extends from X=0 to 50, Y=0 to 3, Z=0 to 40.
        // +Y direction is thickness (into the bracket), +Z direction is height.
        cube([flange_width, plate_thickness, flange_height_vert]);
    }

    // 2. Countersunk holes to subtract from the bracket
    // The countersunk_hole_m4 module creates a hole along +Z.
    // We need to translate and rotate it to match the desired position and orientation.

    // Horizontal flange holes:
    // Located on the top surface (Z = plate_thickness), facing outwards (downwards, -Z).
    // X-coordinate: Center of the flange (flange_width / 2).
    // Y-coordinates: hole_margin and (flange_depth_horiz - hole_margin).
    // Z-coordinate: Top surface of the flange (plate_thickness).
    // Rotation: [180, 0, 0] to make the hole point downwards (-Z).
    translate([flange_width / 2, hole_margin, plate_thickness])
    rotate([180, 0, 0]) // Rotate 180 deg around X-axis to point hole downwards
    countersunk_hole_m4();

    translate([flange_width / 2, flange_depth_horiz - hole_margin, plate_thickness])
    rotate([180, 0, 0]) // Rotate 180 deg around X-axis to point hole downwards
    countersunk_hole_m4();

    // Vertical flange holes:
    // Located on the front surface (Y = plate_thickness), facing outwards (towards +Y).
    // X-coordinate: Center of the flange (flange_width / 2).
    // Y-coordinate: Front surface of the flange (plate_thickness).
    // Z-coordinates: hole_margin and (flange_height_vert - hole_margin).
    // Rotation: [90, 0, 0] to make the hole point towards +Y.
    translate([flange_width / 2, plate_thickness, hole_margin])
    rotate([90, 0, 0]) // Rotate 90 deg around X-axis to point hole towards +Y
    countersunk_hole_m4();

    translate([flange_width / 2, plate_thickness, flange_height_vert - hole_margin])
    rotate([90, 0, 0]) // Rotate 90 deg around X-axis to point hole towards +Y
    countersunk_hole_m4();
}