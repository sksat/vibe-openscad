// M8 hex bolt (thread omitted)

$fn = 180;

// Parameters
af = 13;      // across-flats of hex head [mm]
h  = 5.3;     // height of hex head [mm]
d  = 8;       // shank diameter [mm]
L  = 30;      // shank length [mm]

// Derived
r = af / (2 * cos(30)); // circumscribed radius from across-flats

module hex_prism(across_flats, height) {
  // Flat-to-flat = across_flats
  // Hexagon in XY plane centered at origin
  cylinder(h=height, r=across_flats / (2 * cos(30)), $fn=6, center=false);
}

// Head bottom at z=0, axis along +Z; shank extends into z<0
union() {
  // Hex head: bottom at z=0, top at z=h
  translate([0, 0, 0])
    cylinder(h=h, r=r, $fn=6);

  // Shank: from z=0 down to z=-L
  translate([0, 0, -L])
    cylinder(h=L, d=d, center=false);
}