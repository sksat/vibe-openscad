// Parameters
width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_d = 4.5;
cs_d = 8;
cs_depth = 2;

$fn = 64;

difference() {
    union() {
        // Horizontal flange (+Y direction, thickness in +Z)
        cube([width, depth, thickness], center = false);
        // Vertical flange (+Z direction, thickness in +Y)
        cube([width, thickness, height], center = false);
    }
    // Countersunk holes on horizontal flange (outer face at z = thickness)
    for (ypos = [10, depth - 10]) {
        translate([width / 2, ypos, 0])
            cylinder(d = hole_d, h = thickness + 2);
        translate([width / 2, ypos, thickness - cs_depth])
            cylinder(d = cs_d, h = cs_depth);
    }
    // Countersunk holes on vertical flange (outer face at y = thickness)
    for (zpos = [10, height - 10]) {
        translate([width / 2, thickness, zpos])
            rotate([90, 0, 0])
                cylinder(d = hole_d, h = thickness + 2);
        translate([width / 2, thickness, zpos])
            rotate([90, 0, 0])
                cylinder(d = cs_d, h = cs_depth);
    }
}