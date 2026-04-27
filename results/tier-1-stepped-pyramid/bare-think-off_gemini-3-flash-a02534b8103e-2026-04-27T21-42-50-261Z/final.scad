union() {
    // 1段目 (底辺)
    translate([0, 0, 0])
        cube([60, 60, 10], center = true);

    // 2段目 (中央)
    translate([0, 0, 10])
        cube([40, 40, 10], center = true);

    // 3段目 (頂上)
    translate([0, 0, 20])
        cube([20, 20, 10], center = true);
}