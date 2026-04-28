// M8 hex bolt (threads omitted)

across_flats = 13;
head_height = 5.3;
shank_dia = 8;
shank_len = 30;

// Head: hexagonal prism, bottom at z=0
translate([0, 0, head_height/2])
    cylinder(h = head_height, r = across_flats / sqrt(3), $fn = 6, center = true);

// Shank: cylinder extending into z<0
translate([0, 0, -shank_len])
    cylinder(h = shank_len, d = shank_dia, $fn = 64);