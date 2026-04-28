// M8 hex bolt (thread omitted)

$fn = 180;

// Parameters
af = 13;      // across-flats of hex head [mm]
h  = 5.3;     // head height [mm]
d  = 8;       // shank diameter [mm]
L  = 30;      // shank length [mm]

// Hex head: build centered cylinder with flat-to-flat = af
// For a regular hexagon: across-flats = 2 * apothem = 2 * (R * cos(30)) = R * sqrt(3)
// => circumradius R = af / sqrt(3)
R = af / sqrt(3);

module hex_prism(flat_to_flat, height) {
  $fn = 6;
  // circumradius derived from across-flats
  cylinder(h=height, r=flat_to_flat / sqrt(3), center=false);
}

// Placement: head bottom at z=0, shank extends into z<0
union() {
  // Head
  translate([0, 0, 0])
    hex_prism(af, h);

  // Shank
  translate([0, 0, 0])
    cylinder(h=L, d=d, center=false); // extends from z=0 to z=L
  // Move shank to extend into z<0
  translate([0, 0, -L])
    cylinder(h=L, d=d, center=false);
}