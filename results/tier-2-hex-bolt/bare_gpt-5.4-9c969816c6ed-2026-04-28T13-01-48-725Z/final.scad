$fn = 64;

af = 13;          // across flats
head_h = 5.3;
shank_d = 8;
shank_l = 30;

// Hex head dimensions
head_r = af / sqrt(3);   // circumradius for given across-flats

module hex_bolt_m8() {
    union() {
        // Head: bottom face at z=0, extends in +Z
        cylinder(h = head_h, r = head_r, $fn = 6);

        // Shank: attached to head bottom, extends in -Z
        translate([0, 0, -shank_l])
            cylinder(h = shank_l, d = shank_d);
    }
}

hex_bolt_m8();