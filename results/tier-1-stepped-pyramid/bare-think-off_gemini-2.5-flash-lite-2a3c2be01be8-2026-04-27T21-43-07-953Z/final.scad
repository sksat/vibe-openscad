difference() {
    // Base plate
    cube([60, 60, 10]);

    // Middle plate
    translate([10, 10, 10]) {
        cube([40, 40, 10]);
    }

    // Top plate
    translate([20, 20, 20]) {
        cube([20, 20, 10]);
    }
}