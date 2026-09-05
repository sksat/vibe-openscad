head_across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

union() {
    // Hexagonal head: z = 0 to 5.3
    cylinder(
        h = head_height,
        r = head_across_flats / sqrt(3),
        $fn = 6
    );

    // Cylindrical shank: z = -30 to 0
    translate([0, 0, -shank_length])
        cylinder(
            h = shank_length,
            d = shank_diameter,
            $fn = 96
        );
}