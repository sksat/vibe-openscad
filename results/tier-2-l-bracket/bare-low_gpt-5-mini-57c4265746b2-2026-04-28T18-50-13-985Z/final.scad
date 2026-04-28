// L-bracket with countersunk holes
// Inner corner at origin. Horizontal flange: +Y, thickness along +Z.
// Vertical flange: +Z, thickness along +Y.

$fn = 64;

// Parameters
width = 50;      // X dimension for both flanges
depth = 40;      // Y for horizontal flange
height = 40;     // Z for vertical flange
thickness = 3;   // plate thickness

// Countersink / hole parameters (M4)
clearance_dia = 4.5;
countersink_dia = 8;
countersink_depth = 2;

// Hole positions: 10 mm from left/right edges (X = 10 and X = width-10)
// and 10 mm from outer edge of each flange inward:
// - horizontal flange outer edge at Y = depth -> holes at Y = depth - 10
// - vertical flange outer edge at Z = height -> holes at Z = height - 10
hole_x = [10, width - 10];
hole_y_horizontal = depth - 10;
hole_z_vertical = height - 10;

// Build bracket (union of two plates)
module l_bracket() {
    // horizontal plate: spans X:0..width, Y:0..depth, Z:0..thickness
    cube([width, depth, thickness], center=false);
    // vertical plate: spans X:0..width, Y:0..thickness, Z:0..height
    translate([0,0,0])
        cube([width, thickness, height], center=false);
}

// Countersunk through hole along Z (for horizontal flange)
// countersink faces outward (+Z)
module countersunk_hole_Z(dia_clear, dia_cs, cs_depth) {
    // through hole (make sure long enough to cut through both potential overlaps)
    difference() {
        // through hole
        translate([0,0,-10])
            cylinder(h=thickness+height+20, r=dia_clear/2, center=false);
        // countersink cone located at outer side (+Z)
        // create cone that starts at Z = thickness (outer surface) and goes down by cs_depth
        translate([0,0,thickness - cs_depth])
            cylinder(h=cs_depth, r1=dia_cs/2, r2=0, center=false);
    }
}

// Countersunk through hole along Y (for vertical flange)
// countersink faces outward (+Y)
module countersunk_hole_Y(dia_clear, dia_cs, cs_depth) {
    difference() {
        // through hole along Y
        translate([0,-10,0])
            rotate([0,90,0])
                cylinder(h=thickness+depth+20, r=dia_clear/2, center=false);
        // countersink cone located at outer side (+Y)
        // create cone that starts at Y = thickness (outer surface) and goes inward by cs_depth
        translate([0, thickness - cs_depth, 0])
            rotate([0,90,0])
                cylinder(h=cs_depth, r1=dia_cs/2, r2=0, center=false);
    }
}

// Assemble final part with holes subtracted
difference() {
    l_bracket();

    // Horizontal flange holes (along Z)
    for (x = hole_x) {
        translate([x, hole_y_horizontal, 0])
            countersunk_hole_Z(clearance_dia, countersink_dia, countersink_depth);
    }

    // Vertical flange holes (along Y)
    for (x = hole_x) {
        translate([x, 0, hole_z_vertical])
            countersunk_hole_Y(clearance_dia, countersink_dia, countersink_depth);
    }
}