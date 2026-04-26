// 3段の階段状ピラミッド

// 1段目 (底)
// サイズ: 60mm x 60mm x 10mm
// 中心を原点に配置
cube([60, 60, 10], center = true);

// 2段目 (中央)
// サイズ: 40mm x 40mm x 10mm
// 1段目の上に配置するため、Z軸方向に10mm移動
translate([0, 0, 10]) {
    cube([40, 40, 10], center = true);
}

// 3段目 (上)
// サイズ: 20mm x 20mm x 10mm
// 2段目の上に配置するため、Z軸方向にさらに10mm (合計20mm) 移動
translate([0, 0, 20]) {
    cube([20, 20, 10], center = true);
}