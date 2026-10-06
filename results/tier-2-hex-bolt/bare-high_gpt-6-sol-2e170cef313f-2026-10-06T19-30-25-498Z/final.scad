head_across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

head_radius = head_across_flats / sqrt(3);

union() {
    linear_extrude(height = head_height)
        polygon([
            for (i = [0:5])
                [head_radius * cos(i * 60),
                 head_radius * sin(i * 60)]
        ]);

    translate([0, 0, -shank_length])
        cylinder(h = shank_length, d = shank_diameter, $fn = 64);
}