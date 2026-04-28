$fn = 64;

module m8_bolt() {
    union() {
        // Head: hexagon, across-flats 13mm, height 5.3mm
        cylinder(h = 5.3, r = 6.5 / cos(30), $fn = 6);

        // Shank: cylinder, diameter 8mm, length 30mm extending in -Z
        translate([0, 0, -30])
            cylinder(h = 30, r = 4);
    }
}

m8_bolt();