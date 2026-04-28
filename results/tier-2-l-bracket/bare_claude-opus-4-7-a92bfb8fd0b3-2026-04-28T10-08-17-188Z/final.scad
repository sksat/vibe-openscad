// L-bracket with countersunk holes

$fn = 64;

// Parameters
width = 50;       // X direction
depth = 40;       // Y direction (horizontal flange)
height = 40;      // Z direction (vertical flange)
thickness = 3;    // plate thickness

hole_dia = 4.5;
csk_dia = 8;
csk_depth = 2;
edge_offset = 10;

// Hole positions along the length axis of each flange (from inner corner)
// Each flange: 2 holes, edge_offset from each end of the 40mm dimension
hole_pos1 = edge_offset;
hole_pos2 = depth - edge_offset; // = 30 (also works for height since both 40)

// X positions: symmetric on width, also edge_offset from sides
x1 = edge_offset;
x2 = width - edge_offset;

module countersunk_hole_z() {
    // Hole through Z, countersink on top (+Z)
    union() {
        // through hole
        translate([0, 0, -1])
            cylinder(d = hole_dia, h = thickness + 2);
        // countersink from top surface
        translate([0, 0, thickness - csk_depth])
            cylinder(d = csk_dia, h = csk_depth + 1);
    }
}

module countersunk_hole_y() {
    // Hole through Y, countersink on -Y side (outer side of vertical flange)
    union() {
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(d = hole_dia, h = thickness + 2);
        // countersink on outer face (y = -thickness ... actually outer is y=0? )
        // Vertical flange occupies y in [-thickness, 0], outer is y = -thickness
        translate([0, -thickness, 0])
            rotate([-90, 0, 0])
                cylinder(d = csk_dia, h = csk_depth + 1, center = false);
        // Wait: rotate([-90,0,0]) makes cylinder go in +Y direction from origin
        // We want countersink starting at y=-thickness going in -Y direction (outward)
        // Better approach below
    }
}

// Cleaner version - rebuild
module l_bracket() {
    difference() {
        union() {
            // Horizontal flange: x in [0,width], y in [0,depth], z in [0,thickness]
            // Inner corner at origin, but inner corner means the inside of the L.
            // Horizontal flange extends in +Y, with top surface at z=0 (inner)
            // So horizontal flange: z in [-thickness, 0]
            translate([0, 0, -thickness])
                cube([width, depth, thickness]);
            
            // Vertical flange extends in +Z, inner face at y=0
            // So vertical flange: y in [-thickness, 0], z in [0, height]
            // But we need them to join at the corner properly
            translate([0, -thickness, -thickness])
                cube([width, thickness, height + thickness]);
        }
        
        // Holes in horizontal flange (through Z)
        // Outer surface is at z = -thickness (bottom), countersink there
        for (x = [x1, x2]) {
            for (y = [hole_pos1, hole_pos2]) {
                translate([x, y, 0]) {
                    // through hole
                    translate([0, 0, -thickness - 1])
                        cylinder(d = hole_dia, h = thickness + 2);
                    // countersink from bottom (outer)
                    translate([0, 0, -thickness - 0.01])
                        cylinder(d = csk_dia, h = csk_depth + 0.01);
                }
            }
        }
        
        // Holes in vertical flange (through Y)
        // Outer surface is at y = -thickness, countersink there
        for (x = [x1, x2]) {
            for (z = [hole_pos1, hole_pos2]) {
                translate([x, 0, z]) {
                    // through hole along -Y
                    translate([0, 1, 0])
                        rotate([90, 0, 0])
                            cylinder(d = hole_dia, h = thickness + 2);
                    // countersink on outer face (y = -thickness)
                    translate([0, -thickness + csk_depth + 0.01, 0])
                        rotate([90, 0, 0])
                            cylinder(d = csk_dia, h = csk_depth + 0.01);
                }
            }
        }
    }
}

l_bracket();