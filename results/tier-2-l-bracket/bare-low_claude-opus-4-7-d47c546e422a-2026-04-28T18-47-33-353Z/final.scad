$fn = 64;

width = 50;
depth = 40;
height = 40;
t = 3;

hole_d = 4.5;
cs_d = 8;
cs_depth = 2;

module countersunk_hole_z() {
    // axis along Z, countersink on top (+Z side)
    translate([0, 0, -1])
        cylinder(d = hole_d, h = t + 2);
    translate([0, 0, t - cs_depth])
        cylinder(d = cs_d, h = cs_depth + 1);
}

difference() {
    union() {
        // Horizontal flange
        cube([width, depth, t]);
        // Vertical flange
        cube([width, t, height]);
    }
    
    // Horizontal flange holes (countersink on bottom, -Z side)
    // Center line in Y at y = (t + depth)/2... wait, "面の縁から10mm内側"
    // Holes along width centerline? "各面の中心線上で、面の縁から10mm内側、左右対称に2個"
    // Center line of horizontal face = y center; holes at x = 10 and x = width-10
    // Actually "中心線上" - on the centerline, "面の縁から10mm内側" from edge
    // 2 holes left-right symmetric -> along X axis at y = depth/2
    
    // Horizontal: countersink faces down (outside = -Z)
    for (x = [10, width - 10]) {
        translate([x, (t + depth) / 2, 0])
            rotate([180, 0, 0])
                translate([0, 0, -t])
                    countersunk_hole_z();
    }
    
    // Vertical flange: countersink faces +Y (outside)
    for (x = [10, width - 10]) {
        translate([x, 0, (t + height) / 2])
            rotate([-90, 0, 0])
                countersunk_hole_z();
    }
}