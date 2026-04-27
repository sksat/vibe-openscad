// 底辺 60mm × 60mm × 高さ 10mm の板
cube([60, 60, 10], center = true);

// 40mm × 40mm × 高さ 10mm の板（高さ 10mm の位置に配置）
translate([0, 0, 10])
cube([40, 40, 10], center = true);

// 20mm × 20mm × 高さ 10mm の板（高さ 20mm の位置に配置）
translate([0, 0, 20])
cube([20, 20, 10], center = true);