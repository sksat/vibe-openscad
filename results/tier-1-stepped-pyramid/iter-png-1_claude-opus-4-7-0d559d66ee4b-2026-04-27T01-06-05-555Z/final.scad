// 3段の階段状ピラミッド

// 1段目: 60mm × 60mm × 高さ 10mm
translate([0, 0, 0])
    cube([60, 60, 10], center = true);

// 2段目: 40mm × 40mm × 高さ 10mm
translate([0, 0, 10])
    cube([40, 40, 10], center = true);

// 3段目: 20mm × 20mm × 高さ 10mm
translate([0, 0, 20])
    cube([20, 20, 10], center = true);