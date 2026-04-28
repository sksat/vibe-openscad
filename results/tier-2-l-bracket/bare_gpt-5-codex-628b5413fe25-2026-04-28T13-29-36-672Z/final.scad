width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_d = 4.5;
counter_d = 8;
counter_depth = 2;
edge_offset = 10;

hole_offset_x = width / 2 - edge_offset;
hole_center_y = depth / 2;
hole_center_z = height / 2;

$fn = 64;

module countersunk_hole_z() {
    translate([0, 0, -thickness - 0.2])
        cylinder(d = hole_d, h = thickness + 0.4);
    translate([0, 0, -counter_depth])
        cylinder(d = counter_d, h = counter_depth + 0.1);
}

module countersunk_hole_y() {
    translate([0, -0.1, 0])
        rotate([-90, 0, 0])
            cylinder(d = hole_d, h = thickness + 0.4);
    translate([0, thickness - counter_depth, 0])
        rotate([-90, 0, 0])
            cylinder(d = counter_d, h = counter_depth + 0.1);
}

difference() {
    union() {
        translate([-width / 2, 0, -thickness])
            cube([width, depth, thickness]);
        translate([-width / 2, 0, 0])
            cube([width, thickness, height]);
    }

    for (x = [-hole_offset_x, hole_offset_x])
        translate([x, hole_center_y, 0])
            countersunk_hole_z();

    for (x = [-hole_offset_x, hole_offset_x])
        translate([x, 0, hole_center_z])
            countersunk_hole_y();
}