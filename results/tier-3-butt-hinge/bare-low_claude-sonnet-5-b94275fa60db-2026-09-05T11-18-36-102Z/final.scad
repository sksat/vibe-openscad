// Small butt hinge for furniture - 180 degree open state
$fn = 48;

pin_d = 4;
pin_len = 32;
clearance = 0.3;
knuckle_od = 8;
knuckle_id = pin_d + clearance;

leaf_len = 30;   // along Y (hinge axis)
leaf_w = 25;     // along X (opening direction)
leaf_t = 2;      // thickness along Z

seg = leaf_len / 5; // 6mm

// knuckle segments along Y: 0-6,6-12,12-18,18-24,24-30
// left leaf: segments 0(0-6), 2(12-18), 4(24-30)
// right leaf: segments 1(6-12), 3(18-24)

module knuckle(y_start, y_end) {
    len = y_end - y_start;
    translate([0,y_start,0])
        difference() {
            cylinder(d=knuckle_od, h=len);
            translate([0,0,-0.1])
                cylinder(d=knuckle_id, h=len+0.2);
        }
}

module leaf_plate(side) {
    // side = -1 for left (x<0), +1 for right (x>0)
    // leaf extends from knuckle outward
    knuckle_r = knuckle_od/2;
    x_start = side * knuckle_r;
    x_end = side * (knuckle_r + leaf_w);
    
    difference() {
        // plate body, top surface at z = knuckle_r (so plate aligns with knuckle center)
        translate([min(x_start,x_end), -0.001, knuckle_r - leaf_t])
            cube([leaf_w, leaf_len+0.002, leaf_t]);
        
        // countersunk holes, 3 holes at pitch 8mm, centered along Y
        // place at Y = 15 (center) +/- 8
        for (dy = [-8, 0, 8]) {
            hole_y = leaf_len/2 + dy;
            hole_x = side * (knuckle_r + leaf_w - 6); // away from knuckle side
            translate([hole_x, hole_y, knuckle_r - leaf_t - 0.1]) {
                // through hole
                cylinder(d=3.2, h=leaf_t+0.2);
                // countersink taper from top surface
                translate([0,0, leaf_t - 1 + 0.1])
                    cylinder(d1=3.2, d2=6, h=1);
            }
        }
    }
}

module left_leaf() {
    difference() {
        union() {
            leaf_plate(-1);
            knuckle(0, seg);
            knuckle(2*seg, 3*seg);
            knuckle(4*seg, 5*seg);
        }
    }
}

module right_leaf() {
    union() {
        leaf_plate(1);
        knuckle(seg, 2*seg);
        knuckle(3*seg, 4*seg);
    }
}

module pin() {
    color("silver")
        translate([0, -1, 0])
            cylinder(d=pin_d, h=pin_len);
}

color("darkgray") left_leaf();
color("lightgray") right_leaf();
pin();