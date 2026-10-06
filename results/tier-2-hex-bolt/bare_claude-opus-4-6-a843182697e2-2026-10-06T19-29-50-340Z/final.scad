$fn = 64;

// Head: hexagonal prism, bottom at z=0, top at z=5.3
// across-flats = 13mm, so circumradius = 13 / (2 * cos(30))
head_af = 13;
head_height = 5.3;
head_r = head_af / (2 * cos(30));

// Shank: cylinder diameter 8mm, length 30mm, extending from z=0 downward
shank_d = 8;
shank_length = 30;

// Head
translate([0, 0, head_height / 2])
    cylinder(h = head_height, r = head_r, $fn = 6, center = true);

// Shank
translate([0, 0, -shank_length / 2])
    cylinder(h = shank_length, d = shank_d, center = true);