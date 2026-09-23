// M8 hex bolt (threads omitted)
AF = 13;   // head across-flats
HH = 5.3;  // head height
SD = 8;    // shank diameter
SL = 30;   // shank length

// Hex head: z=0 .. z=HH
linear_extrude(height = HH)
  polygon(sides = 6, radius = AF / sqrt(3));

// Shank: z=-SL .. z=0
translate([0, 0, -SL])
  cylinder(h = SL, d = SD);