// 3段の階段状ピラミッド

module step_pyramid() {
    // 1段目: 60 x 60 x 10
    translate([0, 0, 0])
        cube([60, 60, 10], center = false);

    // 2段目: 40 x 40 x 10
    translate([10, 10, 10])
        cube([40, 40, 10], center = false);

    // 3段目: 20 x 20 x 10
    translate([20, 20, 20])
        cube([20, 20, 10], center = false);
}

step_pyramid();