// 3段の階段状ピラミッド
// 各段は中心を揃えて積み上げる

union() {
    // 1段目: 60mm × 60mm × 高さ10mm
    translate([0, 0, 0])
        cube([60, 60, 10], center = false);

    // 2段目: 40mm × 40mm × 高さ10mm(中心を揃える)
    translate([10, 10, 10])
        cube([40, 40, 10], center = false);

    // 3段目: 20mm × 20mm × 高さ10mm(中心を揃える)
    translate([20, 20, 20])
        cube([20, 20, 10], center = false);
}