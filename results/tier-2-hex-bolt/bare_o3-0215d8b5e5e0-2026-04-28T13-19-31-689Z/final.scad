// M8 Hex Bolt (thread simplified)
// Head: across-flats 13 mm, height 5.3 mm
// Shank: Ø8 mm, length 30 mm (extends toward –Z)

union() {
    // Hexagonal head
    cylinder(h = 5.3, r = 13 / sqrt(3), $fn = 6);

    // Cylindrical shank
    translate([0, 0, -30])
        cylinder(h = 30, r = 4, $fn = 64);
}