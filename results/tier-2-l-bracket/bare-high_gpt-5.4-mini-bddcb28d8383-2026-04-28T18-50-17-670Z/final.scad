$fn = 64;

w = 50;
d = 40;
h = 40;
t = 3;

hole_d = 4.5;
cs_d = 8;
cs_depth = 2;

module cs_hole_z(ypos) {
    translate([0, ypos, 0]) {
        cylinder(d = hole_d, h = t);
        translate([0, 0, t - cs_depth])
            cylinder(d1 = hole_d, d2 = cs_d, h = cs_depth);
    }
}

module cs_hole_y(zpos) {
    translate([0, 0, zpos])
        rotate([90, 0, 0]) {
            cylinder(d = hole_d, h = t);
            translate([0, 0, t - cs_depth])
                cylinder(d1 = hole_d, d2 = cs_d, h = cs_depth);
        }
}

difference() {
    union() {
        translate([-w/2, 0, 0]) cube([w, d, t]);
        translate([-w/2, 0, 0]) cube([w, t, h]);
    }

    for (ypos = [10, d - 10])
        cs_hole_z(ypos);

    for (zpos = [10, h - 10])
        cs_hole_y(zpos);
}