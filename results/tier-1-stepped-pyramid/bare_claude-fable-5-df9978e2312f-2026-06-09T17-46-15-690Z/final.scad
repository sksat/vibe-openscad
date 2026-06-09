// 3段の階段状ピラミッド
// 各段: 60x60, 40x40, 20x20 (高さ各10mm)、中心を揃えて積み上げ

// 1段目
translate([0, 0, 0])
    cube([60, 60, 10], center = false);

// 2段目
translate([10, 10, 10])
    cube([40, 40, 10], center = false);

// 3段目
translate([20, 20, 20])
    cube([20, 20, 10], center = false);