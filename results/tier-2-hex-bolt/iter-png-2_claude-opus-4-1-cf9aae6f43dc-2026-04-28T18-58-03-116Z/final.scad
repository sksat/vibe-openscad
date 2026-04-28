$fn = 50;

// M8 Hex Bolt
union() {
    // Hex head
    cylinder(h = 5.3, d = 13 / cos(30), $fn = 6);
    
    // Shank
    translate([0, 0, -30])
        cylinder(h = 30, d = 8);
}