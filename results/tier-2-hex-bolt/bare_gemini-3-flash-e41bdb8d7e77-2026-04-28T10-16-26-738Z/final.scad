// M8 Hex Bolt (Simplified)

$fn = 64;

// Head: Hexagonal prism
// Across-flats (AF) = 13mm -> Circumradius = (AF/2) / cos(30)
translate([0, 0, 0])
    cylinder(h = 5.3, d = 13 / cos(30), $fn = 6);

// Shank: Cylinder
// Diameter = 8mm, Length = 30mm
// Positioned from z=0 to z=-30
translate([0, 0, -30])
    cylinder(h = 30, d = 8);