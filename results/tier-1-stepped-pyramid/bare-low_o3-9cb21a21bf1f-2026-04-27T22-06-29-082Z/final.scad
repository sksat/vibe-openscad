union() {
    // Bottom layer: 60mm × 60mm × 10mm
    translate([0, 0, 5])
        cube([60, 60, 10], center=true);

    // Middle layer: 40mm × 40mm × 10mm
    translate([0, 0, 15])
        cube([40, 40, 10], center=true);

    // Top layer: 20mm × 20mm × 10mm
    translate([0, 0, 25])
        cube([20, 20, 10], center=true);
}