width = 50;
depth = 40;
height = 40;
thickness = 3;
hole_d = 4.5;
cs_d = 8;
cs_depth = 2;
edge_offset = 10;

horizontal_holes = [edge_offset, depth - edge_offset];
vertical_holes = [edge_offset, height - edge_offset];

module horizontal_flange() {
    translate([-width / 2, 0, 0])
        cube([width, depth, thickness]);
}

module vertical_flange() {
    translate([-width / 2, 0, 0])
        cube([width, thickness, height]);
}

module cs_hole_z(x = 0, y = 0) {
    translate([x, y, -0.1])
        cylinder(h = thickness + 0.2, d = hole_d, $fn = 96);
    translate([x, y, thickness - cs_depth - 0.1])
        cylinder(h = cs_depth + 0.2, d = cs_d, $fn = 96);
}

module cs_hole_y(x = 0, z = 0) {
    translate([x, -0.1, z])
        rotate([-90, 0, 0])
            cylinder(h = thickness + 0.2, d = hole_d, $fn = 96);
    translate([x, thickness - cs_depth - 0.1, z])
        rotate([-90, 0, 0])
            cylinder(h = cs_depth + 0.2, d = cs_d, $fn = 96);
}

difference() {
    union() {
        horizontal_flange();
        vertical_flange();
    }
    for (ypos = horizontal_holes)
        cs_hole_z(0, ypos);
    for (zpos = vertical_holes)
        cs_hole_y(0, zpos);
}