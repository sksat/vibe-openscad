module pyramid() {
    translate([0, 0, 0])
        cube([60, 60, 10], center=true);
    translate([0, 0, 10])
        cube([40, 40, 10], center=true);
    translate([0, 0, 20])
        cube([20, 20, 10], center=true);
}

pyramid();