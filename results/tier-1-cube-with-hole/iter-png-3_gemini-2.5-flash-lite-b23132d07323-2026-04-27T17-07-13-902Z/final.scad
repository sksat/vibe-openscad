module hollow_cube(size, hole_diameter) {
    difference() {
        cube(size, center = true);
        translate([0, 0, -size/2]) cylinder(h = size, d = hole_diameter, center = true);
    }
}

hollow_cube(size = 50, hole_diameter = 20);