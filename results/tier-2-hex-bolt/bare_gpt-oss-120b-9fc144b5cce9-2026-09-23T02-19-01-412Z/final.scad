module m8_bolt() {
    // Hex head (across flats = 13 mm, height = 5.3 mm)
    // Radius of circumscribed circle: r = across_flats / √3
    translate([0, 0, 0])
        cylinder(h = 5.3, r = 13 / sqrt(3), $fn = 6);
    
    // Shank (diameter = 8 mm, length = 30 mm) extending toward -Z
    translate([0, 0, -30])
        cylinder(h = 30, r = 4, $fn = 64);
}

// Render the bolt
m8_bolt();