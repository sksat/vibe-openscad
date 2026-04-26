// 3段の階段状ピラミッド
// 各板は中心を揃えて積み上げる

// 底段: 60x60x10
translate([0, 0, 0]) cube([60, 60, 10], center=true);

// 中段: 40x40x10 (底段の上に載せる)
translate([0, 0, 10]) cube([40, 40, 10], center=true);

// 上段: 20x20x10 (中段の上に載せる)
translate([0, 0, 20]) cube([20, 20, 10], center=true);