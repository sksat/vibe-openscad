// M8 Hex Bolt (Simplified)
// $fn defines the smoothness of the circular shank.
$fn = 64;

// Dimensions
head_across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

// The distance from the center to each vertex of the hexagon
// is calculated as: R = (across-flats) / sqrt(3)
head_radius_vertex = head_across_flats / sqrt(3);

// --- Shank ---
// Placed from z = -30 to z = 0
translate([0, 0, -shank_length])
    cylinder(d=shank_diameter, h=shank_length);

// --- Head ---
// Placed from z = 0 to z = 5.3
// A hexagon is created by taking the hull of 6 small cylinders 
// placed at the vertices of a hexagon.
hull() {
    for (i = [0:5]) {
        rotate([0, 0, i * 60])
            translate([head_radius_vertex, 0, 0])
                cylinder(d=0.1, h=head_height);
    }
}