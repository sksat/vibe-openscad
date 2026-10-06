$fn = 50;

// M8 Hex Bolt

// Head: Across-flats 13mm, Height 5.3mm
// Position: Bottom at z=0
translate([0, 0, 0])
    cylinder(h = 5.3, r = 6.5 / cos(30), $fn = 6);

// Shank: Diameter 8mm, Length 30mm
// Position: Extending towards z < 0
translate([0, 0, -30])
    cylinder(h = 30, d = 8);