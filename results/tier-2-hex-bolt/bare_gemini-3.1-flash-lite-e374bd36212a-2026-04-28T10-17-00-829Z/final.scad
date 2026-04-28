// M8 Hex Bolt (simplified)

// Dimensions
head_af = 13;      // Across-flats
head_height = 5.3;
shank_dia = 8;
shank_len = 30;

// Calculate radius of circumscribed circle for hexagon
// r = (across-flats / 2) / cos(30°) = (across-flats / 2) / (sqrt(3)/2) = across-flats / sqrt(3)
hex_radius = head_af / sqrt(3);

union() {
    // Hexagonal head
    cylinder(r = hex_radius, h = head_height, $fn = 6);
    
    // Shank
    translate([0, 0, -shank_len])
        cylinder(d = shank_dia, h = shank_len, $fn = 50);
}