// M8 hex bolt (thread omitted)

// parameters
across_flats = 13;          // head across-flats (mm)
head_height   = 5.3;        // head thickness (mm)
shank_diameter = 8;         // shank diameter (mm)
shank_length   = 30;        // shank length (mm)

// derived
head_radius = across_flats / sqrt(3);   // circumscribed radius of hex
shank_radius = shank_diameter / 2;

union() {
    // hexagonal head (z = 0 … +head_height)
    cylinder(h = head_height, r = head_radius, $fn = 6);

    // cylindrical shank (z = 0 … -shank_length)
    translate([0, 0, -shank_length])
        cylinder(h = shank_length, r = shank_radius, $fn = 64);
}