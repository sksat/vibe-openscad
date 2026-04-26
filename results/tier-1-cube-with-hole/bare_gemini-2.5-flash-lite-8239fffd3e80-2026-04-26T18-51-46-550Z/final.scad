module hollow_cube(size, hole_diameter) {
    difference() {
        cube(size, center = true);
        cylinder(h = size * 2, d = hole_diameter, center = true);
    }
}

hollow_cube(size = 50, hole_diameter = 20);