// 3段の階段状ピラミッド
step_height = 10;       // 各段の高さ
sizes = [60, 40, 20];   // 各段の一辺の長さ（下から順）

for (i = [0 : len(sizes) - 1]) {
    translate([-sizes[i] / 2, -sizes[i] / 2, i * step_height])
        cube([sizes[i], sizes[i], step_height]);
}