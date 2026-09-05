head_across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

union() {
    cylinder(
        d = head_across_flats / cos(30),
        h = head_height,
        center = false,
        $fn = 6
    );

    translate([0, 0, -shank_length])
        cylinder(
            d = shank_diameter,
            h = shank_length,
            center = false,
            $fn = 96
        );
}