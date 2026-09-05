head_across_flats = 13;
head_height      = 5.3;
shank_diameter   = 8;
shank_length     = 30;

$fn = 96;

union() {
    cylinder(
        h = head_height,
        r = head_across_flats / (2 * cos(30)),
        center = false,
        $fn = 6
    );

    translate([0, 0, -shank_length])
        cylinder(
            h = shank_length,
            d = shank_diameter,
            center = false
        );
}