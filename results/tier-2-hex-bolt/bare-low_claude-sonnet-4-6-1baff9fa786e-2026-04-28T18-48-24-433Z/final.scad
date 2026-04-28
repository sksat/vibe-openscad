// M8 Hex Bolt (thread omitted, cylindrical shank)
// Head bottom face at z=0, shank extends in -Z direction

// Parameters
across_flats = 13;    // Head across-flats (mm)
head_height  = 5.3;   // Head height (mm)
shank_dia    = 8;     // Shank diameter (mm)
shank_len    = 30;    // Shank length (mm)

// Derived
circumradius = (across_flats / 2) / cos(30);  // across-flats to circumradius

// Hex head: bottom at z=0, top at z=head_height
translate([0, 0, 0])
cylinder(h = head_height, r = circumradius, $fn = 6);

// Shank: extends from z=0 down to z=-shank_len
translate([0, 0, -shank_len])
cylinder(h = shank_len, d = shank_dia, $fn = 64);