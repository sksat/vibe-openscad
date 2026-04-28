// M8 hex bolt (thread omitted)
// Dimensions per request:
// - Head: across flats 13 mm, height 5.3 mm
// - Shank: diameter 8 mm, length 30 mm
// - Head base at z=0, shank extends to negative z

af = 13;            // across-flats of hex head (mm)
head_h = 5.3;       // head height (mm)
shank_d = 8;        // shank diameter (mm)
shank_l = 30;       // shank length (mm)

r_hex = af / (2 * cos(30));  // radius for hex prism so AF = 13 mm

union() {
  // Hex head: z from 0 to +head_h
  cylinder(h = head_h, r = r_hex, $fn = 6);

  // Shank: z from -shank_l to 0
  translate([0, 0, -shank_l])
    cylinder(h = shank_l, r = shank_d / 2, $fn = 64);
}