union() {
    // Bottom layer: 60x60x10
    translate([0, 0, 5])
        cube([60, 60, 10], center=true);

    // Middle layer: 40x40x10
    translate([0, 0, 15])
        cube([40, 40, 10], center=true);

    // Top layer: 20x20x10
    translate([0, 0, 25])
        cube([20, 20, 10], center=true);
}