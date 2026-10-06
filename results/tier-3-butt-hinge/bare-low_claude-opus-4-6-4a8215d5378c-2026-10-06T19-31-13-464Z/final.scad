$fn = 60;

// Parameters
leaf_w = 25;
leaf_h = 30;
leaf_t = 2;
pin_d = 4;
pin_len = 32;
knuckle_od = 8;
knuckle_id = 4.6;
knuckle_seg = 6; // each segment height
knuckle_r = knuckle_od / 2;

// Countersink parameters
cs_d_top = 6;
cs_depth = 1;
cs_d_hole = 3.2;
hole_spacing = 8;

module countersink_hole() {
    translate([0, 0, leaf_t - cs_depth])
        cylinder(d1 = cs_d_hole, d2 = cs_d_top, h = cs_depth + 0.01);
    translate([0, 0, -0.01])
        cylinder(d = cs_d_hole, h = leaf_t + 0.02);
}

module leaf(side) {
    // side: -1 for left (x<0), +1 for right (x>0)
    sx = side;
    
    difference() {
        union() {
            // Flat plate - extends from knuckle center outward
            // Plate top surface at z=leaf_t/2 (centered so flat face aligns)
            // 180° open: both plates lie flat, top faces on same plane
            // Place plates with top at z=0 (flat face), bottom at z=-leaf_t
            translate([sx * (leaf_w / 2 + knuckle_r), leaf_h / 2, -leaf_t / 2])
                cube([leaf_w, leaf_h, leaf_t], center = true);
            
            // Knuckles
            if (side == -1) {
                // Left: segments 0, 2, 4 (indices)
                for (i = [0, 2, 4]) {
                    translate([0, i * knuckle_seg, 0])
                        rotate([-90, 0, 0])
                            translate([0, 0, 0])
                                rotate([90, 0, 0])
                                    translate([0, 0, -i * knuckle_seg - knuckle_seg])
                                        cylinder(d = knuckle_od, h = knuckle_seg);
                }
            } else {
                // Right: segments 1, 3
                for (i = [1, 3]) {
                    translate([0, i * knuckle_seg, 0])
                        rotate([-90, 0, 0])
                            translate([0, 0, 0])
                                rotate([90, 0, 0])
                                    translate([0, 0, -i * knuckle_seg - knuckle_seg])
                                        cylinder(d = knuckle_od, h = knuckle_seg);
                }
            }
        }
        
        // Bore through all knuckles for pin
        translate([0, -1, 0])
            cylinder(d = knuckle_id, h = leaf_h + 2);
        
        // Countersink holes - 3 holes along Y, centered on plate
        for (j = [-1, 0, 1]) {
            translate([sx * (knuckle_r + leaf_w / 2), leaf_h / 2 + j * hole_spacing, -leaf_t])
                countersink_hole();
        }
    }
}

// Rewrite with cleaner knuckle approach
// Knuckles along Y axis (0 to 30), each 6mm
// Plate lies in XY plane, z from -leaf_t to 0 (top face at z=0)

module hinge_leaf(side) {
    // side: -1 left, +1 right
    segs = (side == -1) ? [0, 2, 4] : [1, 3];
    
    difference() {
        union() {
            // Plate
            translate([side * knuckle_r, 0, -leaf_t])
                if (side == -1)
                    translate([0, 0, 0]) cube([leaf_w, leaf_h, leaf_t]);
                else
                    translate([-leaf_w, 0, 0]) mirror([1,0,0]) mirror([1,0,0]) cube([leaf_w, leaf_h, leaf_t]);
            
            // Knuckles
            for (i = segs) {
                translate([0, i * knuckle_seg, 0])
                    rotate([-90, 0, 0])
                        cylinder(d = knuckle_od, h = knuckle_seg);
            }
        }
        
        // Pin hole through knuckles
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(d = knuckle_id, h = leaf_h + 2);
        
        // Countersink holes
        cx = (side == -1) ? knuckle_r + leaf_w / 2 : -(knuckle_r + leaf_w / 2);
        for (j = [-1, 0, 1]) {
            translate([cx, leaf_h / 2 + j * hole_spacing, 0]) {
                // From top (z=0) going down
                mirror([0, 0, 1])
                    translate([0, 0, -0.01])
                        cylinder(d1 = cs_d_top, d2 = cs_d_hole, h = cs_depth);
                translate([0, 0, -leaf_t - 0.01])
                    cylinder(d = cs_d_hole, h = leaf_t + 0.02);
            }
        }
    }
}

// Left leaf
color("Silver") hinge_leaf(-1);

// Right leaf  
color("Silver") hinge_leaf(1);

// Pin
color("Gold")
translate([0, -1, 0])
    rotate([-90, 0, 0])
        cylinder(d = pin_d, h = pin_len);