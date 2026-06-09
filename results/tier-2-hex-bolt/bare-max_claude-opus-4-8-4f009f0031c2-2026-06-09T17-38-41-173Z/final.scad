// M8 Hex Bolt (simplified, no threads)
// Head: hex prism, across-flats = 13mm, height = 5.3mm
// Shank: cylinder, diameter = 8mm, length = 30mm
// Head bottom at z=0, shank extends to z<0

$fn = 100;

across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

// across-flats to circumscribed circle radius for hexagon
// width across flats = sqrt(3) * r  =>  r = af / sqrt(3)
hex_radius = across_flats / sqrt(3);

// Head: hexagonal prism above z=0
cylinder(h = head_height, r = hex_radius, $fn = 6);

// Shank: cylinder below z=0
translate([0, 0, -shank_length])
    cylinder(h = shank_length, d = shank_diameter);