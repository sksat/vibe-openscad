// 3段の階段状ピラミッド
step_height = 10;          // 各段の高さ
sizes = [60, 40, 20];      // 各段の一辺の長さ（下から順）

for (i = [0 : len(sizes) - 1]) {
    translate([0, 0, i * step_height + step_height / 2])
        cube([sizes[i], sizes[i], step_height], center = true);
}