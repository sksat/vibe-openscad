// M8 Hex Bolt Parameters
across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

// Calculate the circumradius of the hexagon from the across-flats distance
// r = s / (2 * cos(30°)) = s / sqrt(3)
head_radius = across_flats / sqrt(3);

$fn = 64;

union() {
    // Head: Hexagonal prism
    // Positioned such that the bottom face is at z=0
    cylinder(h = head_height, r = head_radius, $fn = 6);

    // Shank: Cylindrical shaft
    // Extends from z=0 down to z = -shank_length
    translate([0, 0, -shank_length])
    cylinder(h = shank_length, d = shank_diameter);
}