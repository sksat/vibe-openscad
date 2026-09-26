// M8 Hex Bolt (Standard Dimensions)
// $fn defines the smoothness of the circular shank.
$fn = 64;

// Dimensions
head_across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

// The distance from the center to each vertex of the hexagon
// Across-flats (W) and Radius to vertex (R) relationship:
// W = R * sqrt(3)  =>  R = W / sqrt(3)
head_radius_vertex = head_across_flats / sqrt(3);

// --- Shank ---
// Placed from z = -30 to z = 0
translate([0, 0, -shank_length])
    cylinder(d=shank_diameter, h=shank_length);

// --- Head ---
// Placed from z = 0 to z = 5.3
// Using hull() to create a perfect hexagon based on vertex distance.
// The orientation is adjusted so that a flat face is perpendicular to the X-axis.
rotate([0, 0, 30])
hull() {
    for (i = [0:5]) {
        rotate([0, 0, i * 60])
            translate([head_radius_vertex, 0, 0])
                cylinder(d=0.1, h=head_height);
    }
}