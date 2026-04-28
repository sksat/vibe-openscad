// Parameters
leaf_w = 25;
leaf_h = 30;
leaf_t = 2;
knuckle_outer_d = 8;
knuckle_inner_d = 4.3;
pin_d = 4;
pin_l = 32;
knuckle_count = 5;
knuckle_len = leaf_h / knuckle_count; // 6mm
hole_dist = 8;

module hinge() {
    // Left Leaf (x < 0)
    difference() {
        union() {
            translate([-leaf_w, -leaf_h/2, 0]) cube([leaf_w, leaf_h, leaf_t]);
            // Left knuckles: index 0, 2, 4
            for (i = [0, 2, 4]) {
                translate([0, -leaf_h/2 + i * knuckle_len + knuckle_len/2, 0])
                rotate([90, 0, 0]) 
                cylinder(d = knuckle_outer_d, h = knuckle_len, center = true);
            }
        }
        rotate([90, 0, 0]) cylinder(d = knuckle_inner_d, h = leaf_h + 2, center = true);
        for (i = [-1, 0, 1]) {
            translate([-10, i * hole_dist, -1]) {
                cylinder(d1 = 6, d2 = 3.2, h = 1.1);
                cylinder(d = 3.2, h = leaf_t + 2);
            }
        }
    }

    // Right Leaf (x > 0)
    difference() {
        union() {
            translate([0, -leaf_h/2, 0]) cube([leaf_w, leaf_h, leaf_t]);
            // Right knuckles: index 1, 3
            for (i = [1, 3]) {
                translate([0, -leaf_h/2 + i * knuckle_len + knuckle_len/2, 0])
                rotate([90, 0, 0]) 
                cylinder(d = knuckle_outer_d, h = knuckle_len, center = true);
            }
        }
        rotate([90, 0, 0]) cylinder(d = knuckle_inner_d, h = leaf_h + 2, center = true);
        for (i = [-1, 0, 1]) {
            translate([10, i * hole_dist, -1]) {
                cylinder(d1 = 6, d2 = 3.2, h = 1.1);
                cylinder(d = 3.2, h = leaf_t + 2);
            }
        }
    }

    // Pin
    rotate([90, 0, 0]) color("silver") cylinder(d = pin_d, h = pin_l, center = true);
}

$fn = 100;
hinge();