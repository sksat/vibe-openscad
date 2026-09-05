// 3段の階段状ピラミッド

// 1段目（底面）：60mm x 60mm x 高さ10mm
translate([0, 0, 0]) {
    cube([60, 60, 10], center = true);
}

// 2段目（中段）：40mm x 40mm x 高さ10mm
translate([0, 0, 10]) {
    cube([40, 40, 10], center = true);
}

// 3段目（上段）：20mm x 20mm x 高さ10mm
translate([0, 0, 20]) {
    cube([20, 20, 10], center = true);
}