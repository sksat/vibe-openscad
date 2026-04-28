// M8 hex bolt (simplified, no threads)
// Units: mm

$fn = 64;

head_af = 13;      // across flats
head_h  = 5.3;     // head height
shank_d = 8;       // shank diameter
shank_l = 30;      // shank length

head_r = head_af / sqrt(3); // circumradius for regular hex from across-flats

union() {
    // Hex head: bottom face at z=0, extending +Z
    cylinder(h = head_h, r = head_r, $fn = 6);

    // Shank: from z=0 down to z=-30
    translate([0, 0, -shank_l])
        cylinder(h = shank_l, d = shank_d);
}