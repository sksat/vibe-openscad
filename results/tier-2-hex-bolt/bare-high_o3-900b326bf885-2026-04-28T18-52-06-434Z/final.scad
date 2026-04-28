// M8 hex bolt (simplified, no threads)

af            = 13;   // across-flats of hex head [mm]
head_height   = 5.3;  // head height [mm]
shank_d       = 8;    // shank diameter [mm]
shank_length  = 30;   // shank length [mm]

hex_r = af / sqrt(3); // circumradius for the hex head

union() {
    // Hexagonal head (extends in +Z)
    cylinder(h = head_height, r = hex_r, $fn = 6);

    // Cylindrical shank (extends in –Z)
    translate([0, 0, -shank_length])
        cylinder(h = shank_length, d = shank_d, $fn = 64);
}