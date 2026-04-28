// M8 hex bolt (thread omitted)

$fn = 60;

// Parameters
across_flats = 13;   // head across-flats
head_h       = 5.3;  // head height
shank_d      = 8;    // shank diameter
shank_l      = 30;   // shank length (in negative Z direction)

// Derived
head_r = across_flats / 2 / cos(30); // hex circumradius

union() {
    // Head: centered in X-Y, bottom at z=0
    translate([0, 0, head_h/2])
        cylinder(h = head_h, r = head_r, $fn = 6);

    // Shank: extends from z=0 down to z=-(shank_l)
    translate([0, 0, -shank_l/2])
        cylinder(h = shank_l, d = shank_d, $fn = 60);
}