// Parameters
leaf_w   = 30;      // Width along Y (pin axis)
leaf_h   = 25;      // Height along X
leaf_t   = 2;       // Thickness along Z
pin_d    = 4;
pin_l    = 32;
knuckle_d = 8;
hole_clearance = 0.3;
hole_d = pin_d + hole_clearance;     // 4.6 mm

// Knuckle positions (Y)
knuckle_y = [-12, -6, 0, 6, 12];

// Plate holes positions (pitch 8mm along Y)
plate_y = [-12, -4, 4];   // 3 holes per leaf

module leaf(side) {
    // side: -1 for left, +1 for right
    x_offset = side * (leaf_h/2);
    translate([x_offset, 0, leaf_t/2])
        difference() {
            cube([leaf_w, leaf_h, leaf_t], center=true);

            // Pin holes at knuckle positions
            for(y=knuckle_y) {
                translate([0,y,0])
                    rotate([90,0,0])   // hole along Y axis (pin direction)
                        cylinder(h=leaf_t*2, r=hole_d/2, $fn=32);
            }

            // M3 plate holes on opposite side of leaf
            for(y=plate_y) {
                translate([x_offset*sign(side)*1.5,y,0])   // offset slightly into leaf
                    cylinder(h=leaf_t+2, r=3.2/2, $fn=32);
            }
        }
}

module pin() {
    rotate([90,0,0])  // align along Y axis
        cylinder(h=pin_l, r=pin_d/2, $fn=64);
}

// Assemble in 180° open state (both leaves coplanar)
union() {
    leaf(-1);   // left leaf
    leaf(1);    // right leaf
    pin();      // shared pin axis
}