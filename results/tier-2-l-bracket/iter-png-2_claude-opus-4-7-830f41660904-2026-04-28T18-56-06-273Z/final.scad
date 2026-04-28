// L-bracket with countersunk holes

$fn = 64;

// Parameters
width     = 50;   // X direction
depth     = 40;   // Y direction (horizontal flange depth)
height    = 40;   // Z direction (vertical flange height)
thickness = 3;    // plate thickness

hole_dia    = 4.5;
csk_dia     = 8;
csk_depth   = 2;
edge_offset = 10;

eps = 0.05;

// Hole positions: on centerline (x = width/2),
// 10mm from each end along the flange length, symmetrical pair.
x_center = width / 2;
pos_a = edge_offset;          // 10
pos_b = depth - edge_offset;  // 30

module l_bracket() {
    difference() {
        union() {
            // Horizontal flange: inner (top) face at z=0, extends in +Y
            translate([0, 0, -thickness])
                cube([width, depth, thickness]);

            // Vertical flange: inner face at y=0, extends in +Z.
            // Includes corner block (z: -thickness..0) for a clean joint.
            translate([0, -thickness, -thickness])
                cube([width, thickness, height + thickness]);
        }

        // --- Horizontal flange holes (axis along Z) ---
        // Outer face is at z = -thickness (bottom) -> countersink there.
        for (y = [pos_a, pos_b]) {
            translate([x_center, y, 0]) {
                // Through hole
                translate([0, 0, -thickness - eps])
                    cylinder(d = hole_dia, h = thickness + 2*eps);
                // Countersink on outer (-Z) face
                translate([0, 0, -thickness - eps])
                    cylinder(d = csk_dia, h = csk_depth + eps);
            }
        }

        // --- Vertical flange holes (axis along Y) ---
        // Outer face is at y = -thickness -> countersink there.
        for (z = [pos_a, pos_b]) {
            translate([x_center, 0, z]) {
                // Through hole along Y
                translate([0, eps, 0])
                    rotate([90, 0, 0])
                        cylinder(d = hole_dia, h = thickness + 2*eps);
                // Countersink on outer (-Y) face
                translate([0, -thickness + csk_depth + eps, 0])
                    rotate([90, 0, 0])
                        cylinder(d = csk_dia, h = csk_depth + eps);
            }
        }
    }
}

l_bracket();