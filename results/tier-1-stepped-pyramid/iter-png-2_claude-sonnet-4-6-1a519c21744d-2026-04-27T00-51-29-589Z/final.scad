// 3段の階段状ピラミッド

// 各段のパラメータ [幅, 奥行き, 高さ]
stages = [
    [60, 60, 10],  // 1段目（底）
    [40, 40, 10],  // 2段目
    [20, 20, 10]   // 3段目（頂上）
];

// 各段を中心を揃えて積み上げる
for (i = [0 : len(stages) - 1]) {
    z_offset = i * 10;  // 各段の高さは10mm
    translate([0, 0, z_offset])
        cube([stages[i][0], stages[i][1], stages[i][2]], center=true);
}