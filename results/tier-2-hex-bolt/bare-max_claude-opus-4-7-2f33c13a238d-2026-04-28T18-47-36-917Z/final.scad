// M8 Hex Bolt (ISO standard, simplified without thread)
// Head: hex prism, across-flats 13mm, height 5.3mm
// Shank: cylinder, diameter 8mm, length 30mm

$fn = 64;

// Head dimensions
head_af = 13;        // across-flats distance
head_height = 5.3;   // head height

// Shank dimensions
shank_diameter = 8;
shank_length = 30;

// Hex head (centered, bottom at z=0)
translate([0, 0, 0])
    cylinder(h = head_height, r = head_af / sqrt(3), $fn = 6);

// Shank (extends in -Z direction)
translate([0, 0, -shank_length])
    cylinder(h = shank_length, d = shank_diameter);