for (i = [0:2]) {
    translate([0, 0, i * 10])
        cube([60 - i * 20, 60 - i * 20, 10], center = true);
}