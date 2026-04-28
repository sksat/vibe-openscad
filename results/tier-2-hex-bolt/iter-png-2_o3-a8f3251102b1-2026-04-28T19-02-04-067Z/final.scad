// M8 Hex Bolt (threadless)

// Parameters
across_flats = 13;      // distance across flats of hex head [mm]
head_height  = 5.3;     // height of hex head [mm]
shank_dia    = 8;       // shank diameter [mm]
shank_len    = 30;      // shank length [mm]

// Derived value
head_radius = across_flats / (2 * cos(30));  // circumscribed radius for hexagon

union() {
    // Hexagonal head: bottom at z = 0, extending in +Z
    rotate([0,0,30])                       // align a flat horizontally (optional)
        cylinder(h = head_height,
                 r = head_radius,
                 $fn = 6);

    // Cylindrical shank: starts at z = 0, extends in –Z
    translate([0,0,-shank_len])
        cylinder(h = shank_len,
                 r = shank_dia / 2,
                 $fn = 64);
}