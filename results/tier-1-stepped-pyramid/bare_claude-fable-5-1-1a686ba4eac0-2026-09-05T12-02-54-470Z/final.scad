// 3段の階段状ピラミッド
// 各段は中心を揃えて積み上げる

step_height = 10;
sizes = [60, 40, 20];

module stepped_pyramid() {
    for (i = [0 : len(sizes) - 1]) {
        translate([0, 0, i * step_height + step_height / 2])
            cube([sizes[i], sizes[i], step_height], center = true);
    }
}

stepped_pyramid();