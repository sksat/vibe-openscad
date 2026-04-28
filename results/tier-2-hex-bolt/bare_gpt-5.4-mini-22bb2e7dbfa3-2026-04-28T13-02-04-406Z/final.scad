// M8 hex bolt (simplified: no thread)
// Units: mm

$fn = 64;

head_af = 13;     // across flats
head_h  = 5.3;    // head height
shaft_d = 8;      // shank diameter
shaft_l = 30;     // shank length

module hex_prism_af(af, h) {
    // For a regular hexagon: across flats = 2 * r * cos(30°)
    r = af / (2 * cos(30));
    cylinder(h = h, r = r, $fn = 6);
}

union() {
    // Head: bottom face at z = 0, extends to +Z
    hex_prism_af(head_af, head_h);

    // Shaft: centered on axis, extending to -Z
    translate([0, 0, -shaft_l])
        cylinder(h = shaft_l, d = shaft_d);
}