// L-bracket parameters
width = 50;
depth = 40;
height = 40;
thickness = 3;

// Screw hole parameters (M4)
hole_dia = 4.5;
sink_dia = 8.0;
sink_depth = 2.0;
hole_offset = 10; // offset from edge

module countersunk_hole() {
    union() {
        // Through hole
        cylinder(h = thickness * 3, d = hole_dia, center = true, $fn = 32);
        // Countersink (placed at the outer surface)
        translate([0, 0, thickness/2])
            cylinder(h = sink_depth, d1 = hole_dia, d2 = sink_dia, center = false, $fn = 32);
    }
}

difference() {
    // Main Body
    union() {
        // Horizontal flange (Y-axis direction)
        translate([0, 0, -thickness])
            cube([width, depth, thickness]);
        // Vertical flange (Z-axis direction)
        translate([0, -thickness, -thickness])
            cube([width, thickness, height + thickness]);
    }

    // Holes for Horizontal flange (Outer side is bottom Z-)
    translate([width/2 - (width/2 - hole_offset), depth - hole_offset, -thickness/2])
        rotate([180, 0, 0]) countersunk_hole();
    translate([width/2 + (width/2 - hole_offset), depth - hole_offset, -thickness/2])
        rotate([180, 0, 0]) countersunk_hole();

    // Holes for Vertical flange (Outer side is front Y-)
    translate([width/2 - (width/2 - hole_offset), -thickness/2, height - hole_offset])
        rotate([-90, 0, 0]) countersunk_hole();
    translate([width/2 + (width/2 - hole_offset), -thickness/2, height - hole_offset])
        rotate([-90, 0, 0]) countersunk_hole();
}