difference() {
    translate([-25, -25, -25])
        cube([50, 50, 50]);

    cylinder(h = 60, d = 20, center = true, $fn = 100);
}