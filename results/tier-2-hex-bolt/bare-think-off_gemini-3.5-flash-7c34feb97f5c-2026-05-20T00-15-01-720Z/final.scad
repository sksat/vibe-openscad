// OpenSCAD M8 Bolt Model (Simplified)
// - Head: Hexagonal prism, across-flats = 13mm, height = 5.3mm
// - Shank: Diameter = 8mm, length = 30mm, extending in z < 0 direction
// - Position: Head base at z = 0

$fn = 60; // Smoothness for cylindrical parts

module m8_bolt() {
    // Hexagonal Head (z >= 0)
    // In OpenSCAD, a hexagon with across-flats distance 'S' has an outer radius 'r' of:
    // r = S / sqrt(3)
    // S = 13mm -> r = 13 / sqrt(3)
    translate([0, 0, 0])
        rotate([0, 0, 30]) // Align flat faces with axes
            cylinder(h = 5.3, r = 13 / sqrt(3), $fn = 6);

    // Shank (z < 0)
    translate([0, 0, -30])
        cylinder(h = 30, d = 8);
}

m8_bolt();