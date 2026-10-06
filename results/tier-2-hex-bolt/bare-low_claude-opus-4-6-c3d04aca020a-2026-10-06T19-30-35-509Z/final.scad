$fn = 64;

// Head
translate([0, 0, 5.3/2])
    cylinder(h = 5.3, r = 13 / 2 / cos(30), $fn = 6, center = true);

// Shank
translate([0, 0, -30/2])
    cylinder(h = 30, d = 8, center = true);