// 3段の階段状ピラミッド

// 1段目 (底辺 60mm × 60mm × 高さ 10mm)
color("Red")
translate([-30, -30, 0])
cube([60, 60, 10]);

// 2段目 (40mm × 40mm × 高さ 10mm)
color("Green")
translate([-20, -20, 10])
cube([40, 40, 10]);

// 3段目 (20mm × 20mm × 高さ 10mm)
color("Blue")
translate([-10, -10, 20])
cube([20, 20, 10]);