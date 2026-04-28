$fn = 64;

width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_d = 4.5;
csk_d = 8;
csk_depth = 2;

difference() {
    union() {
        // Horizontal flange
        cube([width, depth, thickness]);
        // Vertical flange
        cube([width, thickness, height]);
    }

    // Holes on horizontal flange (countersink on top)
    for (x = [10, width-10]) {
        translate([x, depth/2, 0])
            cylinder(h = thickness, d = hole_d);
        translate([x, depth/2, thickness - csk_depth])
            cylinder(h = csk_depth, d1 = hole_d, d2 = csk_d);
    }

    // Holes on vertical flange (countersink on outer side)
    for (x = [10, width-10]) {
        translate([x, 0, height/2])
            rotate([90, 0, 0])
                cylinder(h = thickness, d = hole_d);
        translate([x, thickness - csk_depth, height/2])
            rotate([90, 0, 0])
                cylinder(h = csk_depth, d1 = hole_d, d2 = csk_d);
    }
}