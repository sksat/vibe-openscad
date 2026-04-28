// L-bracket with countersunk holes

$fn = 64;

// Parameters
width = 50;       // X direction
depth = 40;       // Y direction (horizontal flange depth)
height = 40;      // Z direction (vertical flange height)
thickness = 3;    // plate thickness

hole_dia = 4.5;
csk_dia = 8;
csk_depth = 2;
edge_offset = 10;

// Holes are placed on the centerline of each face (x = width/2),
// 10mm from each edge along the length of the flange.
x_center = width / 2;
pos_a = edge_offset;          // 10mm from inner-corner-side edge
pos_b = depth - edge_offset;  // 10mm from far edge (=30mm)

module l_bracket() {
    difference() {
        union() {
            // Horizontal flange: inner (top) surface at z=0, extends in +Y
            translate([0, 0, -thickness])
                cube([width, depth, thickness]);
            
            // Vertical flange: inner face at y=0, extends in +Z
            // Includes the corner block (z from -thickness to 0) for clean joint
            translate([0, -thickness, -thickness])
                cube([width, thickness, height + thickness]);
        }
        
        // Holes in horizontal flange (through Z), countersink on bottom (outer, -Z)
        for (y = [pos_a, pos_b]) {
            translate([x_center, y, 0]) {
                // through hole
                translate([0, 0, -thickness - 1])
                    cylinder(d = hole_dia, h = thickness + 2);
                // countersink on outer (bottom) face
                translate([0, 0, -thickness - 0.01])
                    cylinder(d = csk_dia, h = csk_depth + 0.01);
            }
        }
        
        // Holes in vertical flange (through Y), countersink on outer (-Y) face
        for (z = [pos_a, pos_b]) {
            translate([x_center, 0, z]) {
                // through hole along Y
                translate([0, 1, 0])
                    rotate([90, 0, 0])
                        cylinder(d = hole_dia, h = thickness + 2);
                // countersink on outer (-Y) face
                translate([0, -thickness + csk_depth + 0.01, 0])
                    rotate([90, 0, 0])
                        cylinder(d = csk_dia, h = csk_depth + 0.01);
            }
        }
    }
}

l_bracket();