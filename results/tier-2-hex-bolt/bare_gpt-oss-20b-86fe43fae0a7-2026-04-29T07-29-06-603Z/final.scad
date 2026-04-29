// M8 hex bolt (head only, no threads)
$fn=100;

// Hexagon parameters
across_flats = 13;      // across-flats distance (mm)
hex_height   = 5.3;     // head height (mm)
shank_diam   = 8;       // shank diameter (mm)
shank_len    = 30;      // shank length (mm)

// Compute radius of circumscribed circle for the hexagon
radius = across_flats / sqrt(3);

// Generate hexagon vertices with flats horizontal
points = [
  for(i=[0:5]) let(
    theta = i*PI/3 + PI/6   // rotate so that flats are vertical
  ) [ radius*cos(theta), radius*sin(theta) ]
];

module hex_head() {
  linear_extrude(height=hex_height)
    polygon(points);
}

module shank() {
  translate([0,0,-shank_len])
    cylinder(h=shank_len, d=shank_diam, center=false);
}

union() {
  hex_head();
  shank();
}