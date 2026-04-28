// M8 hex bolt, simplified shank
$fn = 64;

module hex_bolt_m8() {
    union() {
        // Head: hexagonal prism, across-flats 13mm, height 5.3mm
        // For a hexagon, across-flats = 2 * r * cos(30°)
        // So r = AF / (2*cos(30°))
        translate([0, 0, 0])
            cylinder(h = 5.3, r = 13 / (2 * cos(30)), $fn = 6);

        // Shank: cylindrical shaft, diameter 8mm, length 30mm
        translate([0, 0, -30])
            cylinder(h = 30, d = 8);
    }
}

hex_bolt_m8();