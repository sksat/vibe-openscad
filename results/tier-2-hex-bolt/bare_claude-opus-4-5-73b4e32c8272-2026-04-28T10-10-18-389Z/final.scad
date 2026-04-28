// M8 Hex Bolt (simplified without threads)

// Parameters
head_across_flats = 13;    // Across-flats distance (mm)
head_height = 5.3;         // Head height (mm)
shank_diameter = 8;        // Shank diameter (mm)
shank_length = 30;         // Shank length (mm)

// Calculate circumscribed radius for hexagon
// For a regular hexagon, circumradius = across_flats / sqrt(3)
head_radius = head_across_flats / sqrt(3);

// Hex head (positioned with bottom at z=0, extending upward)
translate([0, 0, head_height/2])
    cylinder(h = head_height, r = head_radius, center = true, $fn = 6);

// Shank (positioned extending downward from z=0)
translate([0, 0, -shank_length/2])
    cylinder(h = shank_length, d = shank_diameter, center = true, $fn = 64);