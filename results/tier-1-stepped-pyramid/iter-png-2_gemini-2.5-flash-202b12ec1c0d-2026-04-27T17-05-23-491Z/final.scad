// 最下段: 60mm x 60mm x 高さ 10mm
cube([60, 60, 10], center = true);

// 中段: 40mm x 40mm x 高さ 10mm
// 最下段の上に配置するため、Z軸方向に10mm移動
translate([0, 0, 10]) {
    cube([40, 40, 10], center = true);
}

// 最上段: 20mm x 20mm x 高さ 10mm
// 最下段と中段の上に配置するため、Z軸方向に20mm移動
translate([0, 0, 20]) {
    cube([20, 20, 10], center = true);
}