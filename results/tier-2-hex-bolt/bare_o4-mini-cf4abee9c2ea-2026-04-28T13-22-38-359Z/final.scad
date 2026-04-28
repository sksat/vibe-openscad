module hex_bolt_m8() {
    union() {
        // Hexagonal head: across-flats = 13mm, height = 5.3mm
        cylinder(h = 5.3, r = 13/sqrt(3), $fn = 6);
        // Shank: diameter = 8mm, length = 30mm, extending into z < 0
        translate([0, 0, -30])
            cylinder(h = 30, r = 4);
    }
}

hex_bolt_m8();