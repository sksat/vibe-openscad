// Parameters
width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_d = 4.5;
cs_d = 8;
cs_depth = 2;

difference() {
    union() {
        // Horizontal flange (+Y direction, thickness in -Z)
        translate([0, 0, -thickness])
            cube([width, depth, thickness], center = false);
        // Vertical flange (+Z direction, thickness in -Y)
        translate([0, -thickness, 0])
            cube([width, thickness, height], center = false);
    }
    // Countersunk holes on horizontal flange
    for (ypos = [10, depth - 10]) {
        translate([width / 2, ypos, -5])
            cylinder(d = hole_d, h = 10, $fn = 64);
        translate([width / 2, ypos, -thickness])
            cylinder(d = cs_d, h = cs_depth, $fn = 64);
    }
    // Countersunk holes on vertical flange
    for (zpos = [10, height - 10]) {
        translate([width / 2, -5, zpos])
            rotate([-90, 0, 0])
                cylinder(d = hole_d, h = 10, $fn = 64);
        translate([width / 2, -thickness, zpos])
            rotate([-90, 0, 0])
                cylinder(d = cs_d, h = cs_depth, $fn = 64);
    }
}