// Stepped pyramid with three layers
union() {
    // Bottom layer: 60x60x10
    translate([-30, -30, 0])
        cube([60, 60, 10]);

    // Middle layer: 40x40x10
    translate([-20, -20, 10])
        cube([40, 40, 10]);

    // Top layer: 20x20x10
    translate([-10, -10, 20])
        cube([20, 20, 10]);
}