$fn = 6;

across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

hex_radius = across_flats / sqrt(3);

union() {
    // Hexagonal head, with its bottom face at z = 0
    cylinder(h = head_height, r = hex_radius);

    // Cylindrical shank extending in the negative Z direction
    translate([0, 0, -shank_length])
        cylinder(h = shank_length, d = shank_diameter, $fn = 64);
}