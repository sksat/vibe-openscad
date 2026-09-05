$fn = 64;

across_flats = 13;
head_height  = 5.3;
shank_diameter = 8;
shank_length = 30;

union() {
    cylinder(
        h = head_height,
        r = across_flats / sqrt(3),
        $fn = 6
    );

    translate([0, 0, -shank_length])
        cylinder(
            h = shank_length,
            d = shank_diameter
        );
}