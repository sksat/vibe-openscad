// 3段の階段状ピラミッド
// 各段は中心を揃えて積み重ねる

height = 10;            // 各段の高さ
sizes  = [60, 40, 20];  // 各段の一辺の長さ（下から上へ）

module step(size, z_pos) {
    translate([0, 0, z_pos])
        cube([size, size, height], center = true);
}

for (i = [0 : len(sizes) - 1]) {
    step(sizes[i], height * i + height / 2);
}