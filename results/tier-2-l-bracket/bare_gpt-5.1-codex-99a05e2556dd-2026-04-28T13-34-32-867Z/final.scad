$fn = 96;

width = 50;
depth = 40;
height = 40;
thickness = 3;
hole_d = 4.5;
cs_d = 8;
cs_depth = 2;

offset = width / 2 - 10;

module horizontal_flange() {
    translate([-width/2, 0, -thickness])
        cube([width, depth, thickness]);
}

module vertical_flange() {
    translate([-width/2, -thickness, 0])
        cube([width, thickness, height]);
}

difference() {
    union() {
        horizontal_flange();
        vertical_flange();
    }

    // Horizontal flange holes
    for (x_pos = [-offset, offset]) {
        translate([x_pos, depth/2, -thickness-1])
            cylinder(h = thickness + 2, r = hole_d/2);
        translate([x_pos, depth/2, -cs_depth])
            cylinder(h = cs_depth, r1 = hole_d/2, r2 = cs_d/2);
    }

    // Vertical flange holes
    for (x_pos = [-offset, offset]) {
        translate([x_pos, -thickness-1, height/2])
            rotate([-90, 0, 0])
                cylinder(h = thickness + 2, r = hole_d/2);
        translate([x_pos, -thickness, height/2])
            rotate([-90, 0, 0])
                cylinder(h = cs_depth, r1 = cs_d/2, r2 = hole_d/2);
    }
}