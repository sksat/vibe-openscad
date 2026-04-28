$fn = 64;

// M8 hex bolt (thread omitted)
// Head: hex prism, across flats = 13 mm, height = 5.3 mm
// Shank: cylinder, diameter = 8 mm, length = 30 mm
// Bolt axis: +Z direction
// Head bottom face at z = 0, shank extends toward negative Z

head_af = 13;
head_h = 5.3;
shank_d = 8;
shank_l = 30;

// For a regular hexagon, across flats = 2 * apothem = sqrt(3) * circumradius
hex_r = head_af / sqrt(3);

union() {
    cylinder(h = head_h, r = hex_r, $fn = 6);
    translate([0, 0, -shank_l])
        cylinder(h = shank_l, d = shank_d);
}