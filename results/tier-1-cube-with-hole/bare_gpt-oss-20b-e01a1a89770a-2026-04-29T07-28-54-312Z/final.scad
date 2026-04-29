difference() {
    cube(50, center = true);
    translate([0, 0, -25]) // extend below the cube to ensure full cut
        cylinder(d = 20, h = 100, $fn=64, center = false);
}