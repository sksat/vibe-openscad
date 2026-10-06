head_across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

union() {
    linear_extrude(height = head_height)
        polygon([
            for (i = [0:5])
                [head_across_flats / sqrt(3) * cos(30 + i * 60),
                 head_across_flats / sqrt(3) * sin(30 + i * 60)]
        ]);

    translate([0, 0, -shank_length])
        cylinder(d = shank_diameter, h = shank_length, $fn = 64);
}