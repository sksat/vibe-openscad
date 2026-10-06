across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;
hex_radius = across_flats / sqrt(3);

union() {
    // 六角頭部: 底面 z=0
    linear_extrude(height = head_height)
        circle(r = hex_radius, $fn = 6);

    // シャンク: z=-30 から z=0
    translate([0, 0, -shank_length])
        cylinder(d = shank_diameter, h = shank_length);
}