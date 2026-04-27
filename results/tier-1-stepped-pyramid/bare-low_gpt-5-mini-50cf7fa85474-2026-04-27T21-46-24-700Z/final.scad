// 3段の階段状ピラミッド
// 各立方板は center=true により X/Y 中心を揃え、Z 方向は中心位置で指定

translate([0, 0, 5])   cube([60, 60, 10], center=true); // 底辺 60x60x10
translate([0, 0, 15])  cube([40, 40, 10], center=true); // 中段 40x40x10
translate([0, 0, 25])  cube([20, 20, 10], center=true); // 上段 20x20x10