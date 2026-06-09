$fn = 64;

width      = 50;
depth      = 40;
height     = 40;
t          = 3;

hole_d     = 4.5;
cs_d       = 8;
cs_depth   = 2;
edge_inset = 10;

difference() {
    union() {
        // 水平フランジ(下面が外側、z = -t ~ 0)
        translate([0, 0, -t])
            cube([width, depth, t]);
        // 垂直フランジ(背面が外側、y = -t ~ 0)
        translate([0, -t, -t])
            cube([width, t, height + t]);
    }

    // 水平面の穴(皿座面は下側=外側)
    for (x = [edge_inset, width - edge_inset]) {
        translate([x, depth / 2, 0]) {
            translate([0, 0, -t - 1])
                cylinder(d = hole_d, h = t + 2);
            translate([0, 0, -t - 0.01])
                cylinder(d1 = cs_d, d2 = hole_d, h = cs_depth);
        }
    }

    // 垂直面の穴(皿座面は背面側=外側)
    for (x = [edge_inset, width - edge_inset]) {
        translate([x, 0, height / 2]) {
            rotate([90, 0, 0]) {
                translate([0, 0, -1])
                    cylinder(d = hole_d, h = t + 2);
                translate([0, 0, t - cs_depth + 0.01])
                    cylinder(d1 = hole_d, d2 = cs_d, h = cs_depth);
            }
        }
    }
}